import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class ManageAppointmentsScreen extends StatefulWidget {
  const ManageAppointmentsScreen({super.key});

  @override
  State<ManageAppointmentsScreen> createState() => _ManageAppointmentsScreenState();
}

class _ManageAppointmentsScreenState extends State<ManageAppointmentsScreen> {
  bool _isLoading = true;
  String _error = '';
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;
  
  Map<DateTime, List<Map<String, dynamic>>> _appointments = {};
  List<Map<String, dynamic>> _selectedDayAppointments = [];
  
  String? _selectedStatus;
  String? _selectedHospital;
  List<String> _statuses = ['الكل', 'قادم', 'مكتمل', 'ملغي'];
  List<String> _hospitals = [];

  @override
  void initState() {
    super.initState();
    _selectedStatus = 'الكل';
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      // TODO: Implement actual API call to load appointments
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      
      // Mock data for demonstration
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      final Map<DateTime, List<Map<String, dynamic>>> appointments = {
        today: [
          {
            'id': '1',
            'patientName': 'أحمد محمد',
            'patientId': 'P001',
            'doctorName': 'د. محمد أحمد',
            'doctorId': 'D001',
            'hospitalName': 'مستشفى الملك فهد',
            'hospitalId': 'H001',
            'time': '10:00 ص',
            'status': 'قادم',
            'reason': 'فحص دوري',
          },
          {
            'id': '2',
            'patientName': 'سارة علي',
            'patientId': 'P002',
            'doctorName': 'د. سارة خالد',
            'doctorId': 'D002',
            'hospitalName': 'مستشفى الأمل',
            'hospitalId': 'H002',
            'time': '11:30 ص',
            'status': 'قادم',
            'reason': 'متابعة',
          },
        ],
        today.add(const Duration(days: 1)): [
          {
            'id': '3',
            'patientName': 'خالد عبدالله',
            'patientId': 'P003',
            'doctorName': 'د. فيصل العمري',
            'doctorId': 'D003',
            'hospitalName': 'مستشفى الملك فهد',
            'hospitalId': 'H001',
            'time': '09:30 ص',
            'status': 'قادم',
            'reason': 'استشارة',
          },
        ],
        today.subtract(const Duration(days: 1)): [
          {
            'id': '4',
            'patientName': 'فاطمة أحمد',
            'patientId': 'P004',
            'doctorName': 'د. نورة السالم',
            'doctorId': 'D004',
            'hospitalName': 'مستشفى الشفاء',
            'hospitalId': 'H003',
            'time': '02:00 م',
            'status': 'مكتمل',
            'reason': 'فحص دوري',
          },
          {
            'id': '5',
            'patientName': 'محمد علي',
            'patientId': 'P005',
            'doctorName': 'د. محمد أحمد',
            'doctorId': 'D001',
            'hospitalName': 'مستشفى الملك فهد',
            'hospitalId': 'H001',
            'time': '03:30 م',
            'status': 'ملغي',
            'reason': 'استشارة',
          },
        ],
      };
      
      // استخراج المستشفيات الفريدة
      final hospitalsSet = <String>{};
      for (final dayAppointments in appointments.values) {
        for (final appointment in dayAppointments) {
          hospitalsSet.add(appointment['hospitalName'] as String);
        }
      }
      
      setState(() {
        _appointments = appointments;
        _selectedDayAppointments = _filterAppointmentsByStatus(
          appointments[_selectedDay] ?? [],
        );
        _hospitals = ['الكل', ...hospitalsSet.toList()..sort()];
        _selectedHospital = 'الكل';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _filterAppointmentsByStatus(List<Map<String, dynamic>> appointments) {
    if (_selectedStatus == 'الكل' && _selectedHospital == 'الكل') {
      return appointments;
    }
    
    return appointments.where((appointment) {
      final matchesStatus = _selectedStatus == 'الكل' || 
          appointment['status'] == _selectedStatus;
      
      final matchesHospital = _selectedHospital == 'الكل' || 
          appointment['hospitalName'] == _selectedHospital;
      
      return matchesStatus && matchesHospital;
    }).toList();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _selectedDayAppointments = _filterAppointmentsByStatus(
          _appointments[selectedDay] ?? [],
        );
      });
    }
  }

  List<Map<String, dynamic>> _getAppointmentsForDay(DateTime day) {
    return _appointments[day] ?? [];
  }

  Future<void> _cancelAppointment(Map<String, dynamic> appointment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الإلغاء'),
        content: Text('هل أنت متأكد من إلغاء موعد ${appointment['patientName']}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'تأكيد',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      setState(() => _isLoading = true);
      
      try {
        // TODO: Implement actual API call to cancel appointment
        await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تم إلغاء موعد ${appointment['patientName']} بنجاح')),
          );
          _loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('حدث خطأ: ${e.toString()}')),
          );
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _completeAppointment(Map<String, dynamic> appointment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الإكمال'),
        content: Text('هل أنت متأكد من تعيين موعد ${appointment['patientName']} كمكتمل؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'تأكيد',
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      setState(() => _isLoading = true);
      
      try {
        // TODO: Implement actual API call to complete appointment
        await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تم تعيين موعد ${appointment['patientName']} كمكتمل بنجاح')),
          );
          _loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('حدث خطأ: ${e.toString()}')),
          );
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _viewAppointmentDetails(Map<String, dynamic> appointment) {
    // TODO: Navigate to appointment details screen
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => AppointmentDetailsScreen(
    //       appointmentId: appointment['id'],
    //     ),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المواعيد'),
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
                        onPressed: _loadData,
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // التقويم
                    Card(
                      margin: EdgeInsets.all(8.w),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8.w),
                        child: TableCalendar(
                          firstDay: DateTime.utc(2023, 1, 1),
                          lastDay: DateTime.utc(2025, 12, 31),
                          focusedDay: _focusedDay,
                          calendarFormat: _calendarFormat,
                          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                          eventLoader: _getAppointmentsForDay,
                          startingDayOfWeek: StartingDayOfWeek.saturday,
                          calendarStyle: CalendarStyle(
                            markersMaxCount: 3,
                            markerDecoration: BoxDecoration(
                              color: AppTheme.primaryGreen,
                              shape: BoxShape.circle,
                            ),
                            selectedDecoration: BoxDecoration(
                              color: AppTheme.primaryGreen,
                              shape: BoxShape.circle,
                            ),
                            todayDecoration: BoxDecoration(
                              color: AppTheme.primaryGreen.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                          ),
                          headerStyle: HeaderStyle(
                            formatButtonVisible: true,
                            titleCentered: true,
                            formatButtonShowsNext: false,
                            formatButtonDecoration: BoxDecoration(
                              color: AppTheme.primaryGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onDaySelected: _onDaySelected,
                          onFormatChanged: (format) {
                            if (_calendarFormat != format) {
                              setState(() {
                                _calendarFormat = format;
                              });
                            }
                          },
                          onPageChanged: (focusedDay) {
                            _focusedDay = focusedDay;
                          },
                        ),
                      ),
                    ),
                    
                    // فلاتر
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      child: Row(
                        children: [
                          // فلتر الحالة
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'الحالة',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 12.h,
                                ),
                              ),
                              value: _selectedStatus,
                              items: _statuses.map((status) => DropdownMenuItem<String>(
                                value: status,
                                child: Text(status),
                              )).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedStatus = value;
                                  _selectedDayAppointments = _filterAppointmentsByStatus(
                                    _appointments[_selectedDay] ?? [],
                                  );
                                });
                              },
                            ),
                          ),
                          SizedBox(width: 16.w),
                          
                          // فلتر المستشفى
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'المستشفى',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 12.h,
                                ),
                              ),
                              value: _selectedHospital,
                              items: _hospitals.map((hospital) => DropdownMenuItem<String>(
                                value: hospital,
                                child: Text(hospital),
                              )).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedHospital = value;
                                  _selectedDayAppointments = _filterAppointmentsByStatus(
                                    _appointments[_selectedDay] ?? [],
                                  );
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // عنوان قائمة المواعيد
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'المواعيد (${_selectedDayAppointments.length})',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            DateFormat('yyyy/MM/dd', 'ar').format(_selectedDay),
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // قائمة المواعيد
                    Expanded(
                      child: _selectedDayAppointments.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 60.w,
                                    color: Colors.grey[400],
                                  ),
                                  SizedBox(height: 16.h),
                                  Text(
                                    'لا توجد مواعيد في هذا اليوم',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              itemCount: _selectedDayAppointments.length,
                              itemBuilder: (context, index) {
                                final appointment = _selectedDayAppointments[index];
                                return _buildAppointmentCard(appointment);
                              },
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    Color statusColor;
    switch (appointment['status']) {
      case 'قادم':
        statusColor = Colors.blue;
        break;
      case 'مكتمل':
        statusColor = Colors.green;
        break;
      case 'ملغي':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }
    
    final isUpcoming = appointment['status'] == 'قادم';
    
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _viewAppointmentDetails(appointment),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // وقت الموعد
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      appointment['time'],
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ),
                  
                  // حالة الموعد
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      appointment['status'],
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              
              // معلومات المريض والطبيب
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'المريض:',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          appointment['patientName'],
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الطبيب:',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          appointment['doctorName'],
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              
              // معلومات المستشفى وسبب الزيارة
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'المستشفى:',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          appointment['hospitalName'],
                          style: TextStyle(
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'سبب الزيارة:',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          appointment['reason'],
                          style: TextStyle(
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              // أزرار الإجراءات
              if (isUpcoming) ...[
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _completeAppointment(appointment),
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      label: const Text(
                        'تعيين كمكتمل',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    TextButton.icon(
                      onPressed: () => _cancelAppointment(appointment),
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      label: const Text(
                        'إلغاء الموعد',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
