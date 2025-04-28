import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';
import '../../appointments/models/appointment.dart';
import '../../appointments/services/appointment_service.dart';
import '../../auth/services/auth_service.dart';
import '../../../core/navigation/app_navigator.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Map<String, dynamic>> _upcomingAppointments = [];
  List<Map<String, dynamic>> _pastAppointments = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAppointments() async {
    // TODO: Implement actual API call to load appointments
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    // Mock data for demonstration
    setState(() {
      _upcomingAppointments = [
        {
          'id': '1',
          'doctorName': 'د. محمد أحمد',
          'doctorSpecialty': 'طب القلب',
          'hospitalName': 'مستشفى الملك فهد',
          'date': DateTime.now().add(const Duration(days: 2)),
          'time': '10:00 ص',
          'status': 'مؤكد',
        },
        {
          'id': '2',
          'doctorName': 'د. سارة خالد',
          'doctorSpecialty': 'طب الأطفال',
          'hospitalName': 'مستشفى الأمل',
          'date': DateTime.now().add(const Duration(days: 5)),
          'time': '11:30 ص',
          'status': 'قيد الانتظار',
        },
      ];

      _pastAppointments = [
        {
          'id': '3',
          'doctorName': 'د. فيصل العمري',
          'doctorSpecialty': 'طب العيون',
          'hospitalName': 'مستشفى النور',
          'date': DateTime.now().subtract(const Duration(days: 10)),
          'time': '09:00 ص',
          'status': 'مكتمل',
          'rated': true,
        },
        {
          'id': '4',
          'doctorName': 'د. نورة السالم',
          'doctorSpecialty': 'طب الأسنان',
          'hospitalName': 'مستشفى الشفاء',
          'date': DateTime.now().subtract(const Duration(days: 20)),
          'time': '02:30 م',
          'status': 'مكتمل',
          'rated': false,
        },
      ];

      _isLoading = false;
    });
  }

  Future<void> _cancelAppointment(String appointmentId) async {
    // TODO: Implement actual API call to cancel appointment
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    setState(() {
      _upcomingAppointments
          .removeWhere((appointment) => appointment['id'] == appointmentId);
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إلغاء الموعد بنجاح')),
      );
    }
  }

  void _rateDoctor(String appointmentId) {
    // TODO: Navigate to rate doctor screen
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => RateDoctorScreen(appointmentId: appointmentId),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مواعيدي'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'المواعيد القادمة'),
            Tab(text: 'المواعيد السابقة'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // المواعيد القادمة
                _upcomingAppointments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 80.w,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'لا توجد مواعيد قادمة',
                              style: TextStyle(
                                fontSize: 18.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 16.h),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/hospitals');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryGreen,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24.w,
                                  vertical: 12.h,
                                ),
                              ),
                              child: const Text('حجز موعد جديد'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(16.w),
                        itemCount: _upcomingAppointments.length,
                        itemBuilder: (context, index) {
                          final appointment = _upcomingAppointments[index];
                          return _buildAppointmentCard(
                            appointment: appointment,
                            isUpcoming: true,
                          );
                        },
                      ),

                // المواعيد السابقة
                _pastAppointments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history,
                              size: 80.w,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'لا توجد مواعيد سابقة',
                              style: TextStyle(
                                fontSize: 18.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(16.w),
                        itemCount: _pastAppointments.length,
                        itemBuilder: (context, index) {
                          final appointment = _pastAppointments[index];
                          return _buildAppointmentCard(
                            appointment: appointment,
                            isUpcoming: false,
                          );
                        },
                      ),
              ],
            ),
    );
  }

  Widget _buildAppointmentCard({
    required Map<String, dynamic> appointment,
    required bool isUpcoming,
  }) {
    final dateFormat = DateFormat('yyyy/MM/dd', 'ar');
    final date = appointment['date'] as DateTime;
    final formattedDate = dateFormat.format(date);

    Color statusColor;
    switch (appointment['status']) {
      case 'مؤكد':
        statusColor = Colors.green;
        break;
      case 'قيد الانتظار':
        statusColor = Colors.orange;
        break;
      case 'مكتمل':
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  appointment['doctorName'],
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              appointment['doctorSpecialty'],
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(Icons.local_hospital, size: 16.w, color: Colors.grey[600]),
                SizedBox(width: 4.w),
                Text(
                  appointment['hospitalName'],
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16.w, color: Colors.grey[600]),
                SizedBox(width: 4.w),
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(width: 16.w),
                Icon(Icons.access_time, size: 16.w, color: Colors.grey[600]),
                SizedBox(width: 4.w),
                Text(
                  appointment['time'],
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isUpcoming)
                  TextButton.icon(
                    onPressed: () => _cancelAppointment(appointment['id']),
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    label: const Text(
                      'إلغاء الموعد',
                      style: TextStyle(color: Colors.red),
                    ),
                  )
                else if (appointment['status'] == 'مكتمل' &&
                    appointment['rated'] == false)
                  TextButton.icon(
                    onPressed: () => _rateDoctor(appointment['id']),
                    icon: const Icon(Icons.star, color: Colors.amber),
                    label: const Text(
                      'تقييم الطبيب',
                      style: TextStyle(color: Colors.amber),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
