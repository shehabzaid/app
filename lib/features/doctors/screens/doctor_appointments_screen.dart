import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/navigation/app_navigator.dart';

class DoctorAppointmentsScreen extends StatefulWidget {
  final String doctorId;

  const DoctorAppointmentsScreen({
    super.key,
    required this.doctorId,
  });

  @override
  State<DoctorAppointmentsScreen> createState() =>
      _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen> {
  bool _isLoading = true;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;

  Map<DateTime, List<Map<String, dynamic>>> _appointments = {};
  List<Map<String, dynamic>> _selectedDayAppointments = [];

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
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
          'patientAge': 45,
          'time': '10:00 ص',
          'status': 'قادم',
          'reason': 'فحص دوري',
        },
        {
          'id': '2',
          'patientName': 'سارة علي',
          'patientAge': 32,
          'time': '11:30 ص',
          'status': 'قادم',
          'reason': 'متابعة',
        },
        {
          'id': '3',
          'patientName': 'خالد عبدالله',
          'patientAge': 60,
          'time': '01:00 م',
          'status': 'قادم',
          'reason': 'استشارة',
        },
      ],
      today.add(const Duration(days: 1)): [
        {
          'id': '4',
          'patientName': 'فاطمة أحمد',
          'patientAge': 28,
          'time': '09:30 ص',
          'status': 'قادم',
          'reason': 'فحص دوري',
        },
        {
          'id': '5',
          'patientName': 'محمد علي',
          'patientAge': 50,
          'time': '12:00 م',
          'status': 'قادم',
          'reason': 'متابعة',
        },
      ],
      today.add(const Duration(days: 3)): [
        {
          'id': '6',
          'patientName': 'نورة السالم',
          'patientAge': 35,
          'time': '10:30 ص',
          'status': 'قادم',
          'reason': 'استشارة',
        },
      ],
      today.subtract(const Duration(days: 1)): [
        {
          'id': '7',
          'patientName': 'عبدالله محمد',
          'patientAge': 42,
          'time': '11:00 ص',
          'status': 'مكتمل',
          'reason': 'فحص دوري',
        },
        {
          'id': '8',
          'patientName': 'ليلى خالد',
          'patientAge': 55,
          'time': '02:30 م',
          'status': 'مكتمل',
          'reason': 'متابعة',
        },
      ],
    };

    setState(() {
      _appointments = appointments;
      _selectedDayAppointments = appointments[_selectedDay] ?? [];
      _isLoading = false;
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _selectedDayAppointments = _appointments[selectedDay] ?? [];
      });
    }
  }

  List<Map<String, dynamic>> _getAppointmentsForDay(DateTime day) {
    return _appointments[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مواعيد الطبيب'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
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
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDay, day),
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

                // عنوان قائمة المواعيد
                Padding(
                  padding: EdgeInsets.all(16.w),
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

    final isPast =
        appointment['status'] == 'مكتمل' || appointment['status'] == 'ملغي';

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          // التنقل إلى تفاصيل الموعد للطبيب
          AppNavigator.navigateToDoctorAppointmentDetails(
            context,
            appointment['id'],
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              // وقت الموعد
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  appointment['time'],
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(width: 12.w),

              // معلومات المريض
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment['patientName'],
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'العمر: ${appointment['patientAge']} سنة',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'السبب: ${appointment['reason']}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // أزرار الإجراءات
              Column(
                children: [
                  // حالة الموعد
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      appointment['status'],
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // زر الإجراء
                  if (!isPast)
                    ElevatedButton(
                      onPressed: () {
                        // التنقل إلى تفاصيل الموعد للطبيب
                        AppNavigator.navigateToDoctorAppointmentDetails(
                          context,
                          appointment['id'],
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('بدء الكشف'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
