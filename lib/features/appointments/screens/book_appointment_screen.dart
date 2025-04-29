import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;
import '../../../core/theme/app_theme.dart';
import '../models/appointment.dart';
import '../services/appointment_service.dart';
import '../../../features/auth/services/auth_service.dart';
import '../../../features/hospitals/services/hospital_service.dart';
import '../../../features/hospitals/models/hospital.dart';
import '../../../features/hospitals/models/doctor.dart';
import '../../../features/notifications/utils/notification_helper.dart';

class BookAppointmentScreen extends StatefulWidget {
  final String? hospitalId;
  final String? departmentId;
  final String? doctorId;

  const BookAppointmentScreen({
    Key? key,
    this.hospitalId,
    this.departmentId,
    this.doctorId,
  }) : super(key: key);

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final AppointmentService _appointmentService = AppointmentService();
  final AuthService _authService = AuthService();
  final HospitalService _hospitalService = HospitalService();
  final NotificationHelper _notificationHelper = NotificationHelper();

  bool _isLoading = false;
  bool _isInitializing = true;
  String? _errorMessage;
  String? _userId;

  List<Hospital> _hospitals = [];
  List<Doctor> _doctors = [];
  Hospital? _selectedHospital;
  Doctor? _selectedDoctor;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    try {
      final currentUser = await _authService.getCurrentUserProfile();
      if (currentUser == null) {
        setState(() {
          _errorMessage = 'لم يتم العثور على بيانات المستخدم';
          _isInitializing = false;
        });
        return;
      }

      setState(() {
        _userId = currentUser.id;
      });

      // Cargar hospitales
      final hospitals = await _hospitalService.getAllHospitals();
      setState(() {
        _hospitals = hospitals;
      });

      // Si se proporciona un ID de hospital, seleccionarlo
      if (widget.hospitalId != null && widget.hospitalId!.isNotEmpty) {
        final hospital = hospitals.firstWhere(
          (h) => h.id == widget.hospitalId,
          orElse: () => hospitals.first,
        );

        setState(() {
          _selectedHospital = hospital;
        });

        await _loadDoctors(hospital.id);

        // Si se proporciona un ID de médico, seleccionarlo
        if (widget.doctorId != null &&
            widget.doctorId!.isNotEmpty &&
            _doctors.isNotEmpty) {
          try {
            final doctor = _doctors.firstWhere(
              (d) => d.id == widget.doctorId,
            );

            setState(() {
              _selectedDoctor = doctor;
            });
          } catch (e) {
            // Si no se encuentra el doctor, seleccionar el primero de la lista
            if (_doctors.isNotEmpty) {
              setState(() {
                _selectedDoctor = _doctors.first;
              });
            }
          }
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'فشل في تحميل البيانات: $e';
      });
    } finally {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  Future<void> _loadDoctors(String hospitalId) async {
    try {
      final doctors = await _hospitalService.getDoctorsByHospital(hospitalId);
      setState(() {
        _doctors = doctors;
        _selectedDoctor = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'فشل في تحميل قائمة الأطباء: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حجز موعد'),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isInitializing) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.red,
                fontSize: 16.sp,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: _initializeScreen,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: FormBuilder(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'المنشأة الصحية:',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            _buildHospitalDropdown(),
            SizedBox(height: 16.h),
            Text(
              'الطبيب:',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            _buildDoctorDropdown(),
            SizedBox(height: 16.h),
            Text(
              'تاريخ الموعد:',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            _buildDatePicker(),
            SizedBox(height: 16.h),
            Text(
              'وقت الموعد:',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            _buildTimePicker(),
            SizedBox(height: 16.h),
            Text(
              'ملاحظات:',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            FormBuilderTextField(
              name: 'notes',
              decoration: InputDecoration(
                hintText: 'أدخل أي ملاحظات إضافية',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16.h),
            FormBuilderCheckbox(
              name: 'is_virtual',
              title: Text(
                'موعد افتراضي (عن بعد)',
                style: TextStyle(
                  fontSize: 16.sp,
                ),
              ),
              initialValue: false,
            ),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20.h,
                        width: 20.w,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'حجز الموعد',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHospitalDropdown() {
    return FormBuilderDropdown<Hospital>(
      name: 'hospital',
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 12.h,
        ),
      ),
      items: _hospitals.map((hospital) {
        return DropdownMenuItem<Hospital>(
          value: hospital,
          child: Text(hospital.nameArabic),
        );
      }).toList(),
      initialValue: _selectedHospital,
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(errorText: 'يرجى اختيار المنشأة الصحية'),
      ]),
      onChanged: (hospital) {
        if (hospital != null && (hospital != _selectedHospital)) {
          setState(() {
            _selectedHospital = hospital;
            _selectedDoctor = null;
          });
          _loadDoctors(hospital.id);
        }
      },
    );
  }

  Widget _buildDoctorDropdown() {
    return FormBuilderDropdown<Doctor>(
      name: 'doctor',
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 12.h,
        ),
        hintText: _selectedHospital == null
            ? 'اختر المنشأة الصحية أولاً'
            : 'اختر الطبيب',
      ),
      items: _doctors.map((doctor) {
        return DropdownMenuItem<Doctor>(
          value: doctor,
          child: Text(doctor.nameArabic),
        );
      }).toList(),
      initialValue: _selectedDoctor,
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(errorText: 'يرجى اختيار الطبيب'),
      ]),
      onChanged: (doctor) {
        setState(() {
          _selectedDoctor = doctor;
        });
      },
      enabled: _selectedHospital != null && _doctors.isNotEmpty,
    );
  }

  Widget _buildDatePicker() {
    return FormBuilderDateTimePicker(
      name: 'appointment_date',
      inputType: InputType.date,
      format: DateFormat('yyyy/MM/dd'),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 12.h,
        ),
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(errorText: 'يرجى اختيار تاريخ الموعد'),
      ]),
    );
  }

  Widget _buildTimePicker() {
    return FormBuilderDateTimePicker(
      name: 'appointment_time',
      inputType: InputType.time,
      format: DateFormat('HH:mm'),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 12.h,
        ),
        suffixIcon: const Icon(Icons.access_time),
      ),
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(errorText: 'يرجى اختيار وقت الموعد'),
      ]),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final formData = _formKey.currentState!.value;

        if (_userId == null) {
          throw Exception('لم يتم العثور على بيانات المستخدم');
        }

        final hospital = formData['hospital'] as Hospital;
        final doctor = formData['doctor'] as Doctor;
        final appointmentDate = formData['appointment_date'] as DateTime;
        final appointmentTime = formData['appointment_time'] as DateTime;
        final notes = formData['notes'] as String?;
        final isVirtual = formData['is_virtual'] as bool? ?? false;

        // Formatear la hora
        final timeFormat = DateFormat('HH:mm:ss');
        final formattedTime = timeFormat.format(appointmentTime);

        final appointment = Appointment(
          id: '', // Se generará automáticamente en la base de datos
          patientId: _userId!,
          doctorId: doctor.id,
          facilityId: hospital.id,
          departmentId: doctor.departmentId,
          appointmentDate: appointmentDate,
          appointmentTime: formattedTime,
          isVirtual: isVirtual,
          status: 'Pending',
          notes: notes,
          createdAt: DateTime.now(),
        );

        // حجز الموعد
        final createdAppointment =
            await _appointmentService.bookAppointment(appointment);

        // إرسال إشعار للطبيب
        final currentUser = await _authService.getCurrentUserProfile();
        if (currentUser != null && createdAppointment != null) {
          // تنسيق التاريخ والوقت
          final appointmentDateTime = DateTime(
            appointmentDate.year,
            appointmentDate.month,
            appointmentDate.day,
            appointmentTime.hour,
            appointmentTime.minute,
          );

          // إرسال إشعار للطبيب
          await _notificationHelper.sendNewAppointmentNotificationToDoctor(
            doctorId: doctor.id,
            patientName: currentUser.fullName ?? currentUser.email,
            appointmentDateTime: appointmentDateTime,
            appointmentId: createdAppointment.id,
          );

          developer.log('تم إرسال إشعار للطبيب بنجاح');
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حجز الموعد بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('حدث خطأ: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}
