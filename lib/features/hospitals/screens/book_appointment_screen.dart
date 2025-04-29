import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;
import '../services/hospital_service.dart';
import '../models/doctor.dart';
import 'package:intl/intl.dart' as intl;

class BookAppointmentScreen extends StatefulWidget {
  final String hospitalId;
  final String departmentId;
  final String? doctorId;

  const BookAppointmentScreen({
    super.key,
    required this.hospitalId,
    required this.departmentId,
    this.doctorId,
  });

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final _hospitalService = HospitalService();
  final _notesController = TextEditingController();

  bool _isLoading = true;
  String _error = '';
  Doctor? _selectedDoctor;
  List<Doctor> _doctors = [];
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  List<Map<String, dynamic>> _availableSlots = [];
  Map<String, dynamic>? _selectedSlot;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    try {
      setState(() => _isLoading = true);

      List<Doctor> doctors = [];

      // إذا كان معرف القسم فارغًا، نحاول الحصول على الطبيب مباشرة
      if (widget.departmentId.isEmpty && widget.doctorId != null) {
        try {
          final doctor =
              await _hospitalService.getDoctorDetails(widget.doctorId!);
          doctors = [doctor];
          developer.log('Loaded doctor directly: ${doctor.nameArabic}');
        } catch (e) {
          developer.log('Error loading doctor directly: $e');
          // إذا فشل، نحاول الحصول على جميع أطباء المستشفى
          doctors =
              await _hospitalService.getDoctorsByHospital(widget.hospitalId);
        }
      } else {
        // الحصول على أطباء القسم
        doctors =
            await _hospitalService.getDepartmentDoctors(widget.departmentId);
      }

      setState(() {
        _doctors = doctors;
        if (widget.doctorId != null && doctors.isNotEmpty) {
          try {
            _selectedDoctor =
                doctors.firstWhere((d) => d.id == widget.doctorId);
          } catch (e) {
            // إذا لم يتم العثور على الطبيب في القائمة، نستخدم الطبيب الأول
            if (doctors.isNotEmpty) {
              _selectedDoctor = doctors.first;
            }
          }
        }
        _error = '';
      });

      if (_selectedDoctor != null) {
        await _loadAvailableSlots();
      }
    } catch (e) {
      developer.log('Error in _loadDoctors: $e');
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadAvailableSlots() async {
    if (_selectedDoctor == null) return;

    try {
      setState(() => _isLoading = true);

      final endDate = _selectedDay.add(const Duration(days: 30));
      final slots = await _hospitalService.getDoctorAvailableAppointments(
        _selectedDoctor!.id,
        _selectedDay,
        endDate,
      );

      setState(() {
        _availableSlots = slots;
        _selectedSlot = null;
        _error = '';
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _bookAppointment() async {
    if (_selectedSlot == null) return;

    try {
      setState(() => _isLoading = true);

      // الحصول على معرف المستخدم الحالي من خدمة المصادقة
      final currentUser = Supabase.instance.client.auth.currentUser;
      final patientId = currentUser?.id ?? '';

      if (patientId.isEmpty) {
        // إذا لم يكن المستخدم مسجل الدخول، نطلب منه تسجيل الدخول
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('يرجى تسجيل الدخول أولاً لحجز موعد'),
              backgroundColor: Colors.red,
            ),
          );
          // التنقل إلى صفحة تسجيل الدخول مع الاحتفاظ بالمسار الحالي
          Navigator.pushNamedAndRemoveUntil(
              context, '/login', (route) => false);
        }
        return;
      }

      await _hospitalService.bookAppointment(
        patientId: patientId,
        appointmentId: _selectedSlot!['id'],
        hospitalId: widget.hospitalId,
        departmentId: widget.departmentId,
        doctorId: _selectedDoctor?.id,
        notes: _notesController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حجز الموعد بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      developer.log('Error booking appointment: $e');
      if (mounted) {
        setState(() => _error = e.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في حجز الموعد: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حجز موعد'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        _error,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: _loadDoctors,
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.doctorId == null) ...[
                        // اختيار الطبيب
                        Text(
                          'اختر الطبيب',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        DropdownButtonFormField<Doctor>(
                          value: _selectedDoctor,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          items: _doctors.map((doctor) {
                            return DropdownMenuItem(
                              value: doctor,
                              child: Text(doctor.nameArabic),
                            );
                          }).toList(),
                          onChanged: (doctor) {
                            setState(() => _selectedDoctor = doctor);
                            _loadAvailableSlots();
                          },
                        ),
                        SizedBox(height: 24.h),
                      ],
                      if (_selectedDoctor != null) ...[
                        // التقويم
                        _buildCalendar(),
                        SizedBox(height: 24.h),

                        // المواعيد المتاحة
                        Text(
                          'المواعيد المتاحة',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        if (_availableSlots.isEmpty)
                          const Center(
                            child: Text('لا توجد مواعيد متاحة في هذا اليوم'),
                          )
                        else
                          Wrap(
                            spacing: 8.w,
                            runSpacing: 8.h,
                            children: _availableSlots
                                .where((slot) => isSameDay(
                                    DateTime.parse(slot['date']), _selectedDay))
                                .map((slot) {
                              final startTime = TimeOfDay.fromDateTime(
                                  DateTime.parse(
                                      '${slot['date']} ${slot['start_time']}'));
                              return ChoiceChip(
                                label: Text(intl.DateFormat.jm().format(
                                    DateTime(2022, 1, 1, startTime.hour,
                                        startTime.minute))),
                                selected: _selectedSlot == slot,
                                onSelected: (selected) {
                                  setState(() =>
                                      _selectedSlot = selected ? slot : null);
                                },
                              );
                            }).toList(),
                          ),
                        SizedBox(height: 24.h),

                        // ملاحظات
                        TextField(
                          controller: _notesController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'ملاحظات (اختياري)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        SizedBox(height: 24.h),

                        // زر الحجز
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                _selectedSlot == null ? null : _bookAppointment,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                            ),
                            child: const Text('تأكيد الحجز'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.now(),
      lastDay: DateTime.now().add(const Duration(days: 30)),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      calendarFormat: _calendarFormat,
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
          _loadAvailableSlots();
        });
      },
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}
