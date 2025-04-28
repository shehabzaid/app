import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/navigation/app_navigator.dart';
import 'package:intl/intl.dart';

class DoctorHomeScreen extends StatefulWidget {
  final String doctorId;

  const DoctorHomeScreen({
    super.key,
    required this.doctorId,
  });

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _doctorInfo;
  List<Map<String, dynamic>> _todayAppointments = [];
  List<Map<String, dynamic>> _recentMedicalRecords = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDoctorData();
  }

  Future<void> _loadDoctorData() async {
    // TODO: Implement actual API calls to load doctor data
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    // Mock data for demonstration
    setState(() {
      _doctorInfo = {
        'id': widget.doctorId,
        'name': 'د. محمد أحمد',
        'specialty': 'طب القلب',
        'hospital': 'مستشفى الملك فهد',
        'imageUrl': null,
      };

      _todayAppointments = [
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
      ];

      _recentMedicalRecords = [
        {
          'id': '1',
          'patientName': 'فيصل العمري',
          'patientAge': 55,
          'date': DateTime.now().subtract(const Duration(days: 1)),
          'diagnosis': 'ارتفاع ضغط الدم',
        },
        {
          'id': '2',
          'patientName': 'نورة السالم',
          'patientAge': 28,
          'date': DateTime.now().subtract(const Duration(days: 2)),
          'diagnosis': 'التهاب الحلق',
        },
      ];

      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم الطبيب'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              AppNavigator.navigateToNotifications(context);
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDoctorData,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // معلومات الطبيب
                    _buildDoctorInfoCard(),
                    SizedBox(height: 24.h),

                    // إحصائيات سريعة
                    _buildStatsRow(),
                    SizedBox(height: 24.h),

                    // مواعيد اليوم
                    _buildSectionTitle('مواعيد اليوم', Icons.calendar_today),
                    SizedBox(height: 8.h),
                    _todayAppointments.isEmpty
                        ? _buildEmptyState('لا توجد مواعيد لهذا اليوم')
                        : Column(
                            children: _todayAppointments
                                .map((appointment) =>
                                    _buildAppointmentCard(appointment))
                                .toList(),
                          ),
                    SizedBox(height: 24.h),

                    // أحدث السجلات الطبية
                    _buildSectionTitle(
                        'أحدث السجلات الطبية', Icons.medical_information),
                    SizedBox(height: 8.h),
                    _recentMedicalRecords.isEmpty
                        ? _buildEmptyState('لا توجد سجلات طبية حديثة')
                        : Column(
                            children: _recentMedicalRecords
                                .map(
                                    (record) => _buildMedicalRecordCard(record))
                                .toList(),
                          ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index != _currentIndex) {
            setState(() => _currentIndex = index);
            AppNavigator.handleDoctorBottomNavigation(
                context, index, widget.doctorId);
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryGreen,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'المواعيد',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_information),
            label: 'السجلات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'حسابي',
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            // صورة الطبيب
            CircleAvatar(
              radius: 40.r,
              backgroundColor: Colors.grey[200],
              backgroundImage: _doctorInfo?['imageUrl'] != null
                  ? NetworkImage(_doctorInfo!['imageUrl'])
                  : null,
              child: _doctorInfo?['imageUrl'] == null
                  ? Icon(
                      Icons.person,
                      size: 40.r,
                      color: Colors.grey[400],
                    )
                  : null,
            ),
            SizedBox(width: 16.w),

            // معلومات الطبيب
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _doctorInfo!['name'],
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _doctorInfo!['specialty'],
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _doctorInfo!['hospital'],
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    final today = DateTime.now();
    final dateFormat = DateFormat('yyyy/MM/dd', 'ar');
    final formattedDate = dateFormat.format(today);

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'مواعيد اليوم',
            value: _todayAppointments.length.toString(),
            icon: Icons.calendar_today,
            color: Colors.blue,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: _buildStatCard(
            title: 'التاريخ',
            value: formattedDate,
            icon: Icons.date_range,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 32.w,
            ),
            SizedBox(height: 8.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: AppTheme.primaryGreen,
              size: 24.w,
            ),
            SizedBox(width: 8.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () {
            // TODO: Navigate to full list
          },
          child: const Text('عرض الكل'),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h),
        child: Text(
          message,
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.grey[600],
          ),
        ),
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

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          AppNavigator.navigateToPatientDetails(
            context,
            appointment['id'],
            appointmentId: appointment['id'],
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicalRecordCard(Map<String, dynamic> record) {
    final date = record['date'] as DateTime;
    final dateFormat = DateFormat('yyyy/MM/dd', 'ar');
    final formattedDate = dateFormat.format(date);

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          AppNavigator.navigateToPatientDetails(
            context,
            record['id'],
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              // أيقونة السجل الطبي
              Container(
                width: 50.w,
                height: 50.w,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.medical_information,
                  color: Colors.green,
                  size: 24.w,
                ),
              ),
              SizedBox(width: 12.w),

              // معلومات السجل
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record['patientName'],
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'التشخيص: ${record['diagnosis']}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // زر عرض التفاصيل
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 16),
                onPressed: () {
                  // TODO: Navigate to medical record details
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
