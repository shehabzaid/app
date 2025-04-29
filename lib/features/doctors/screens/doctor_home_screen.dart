import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/navigation/app_navigator.dart';
import '../../../features/hospitals/models/doctor.dart';
import '../../../features/hospitals/services/hospital_service.dart';
import '../../../features/appointments/models/appointment.dart';
import '../../../features/appointments/services/appointment_service.dart';
import '../../../features/medical_records/models/medical_record.dart';
import '../../../features/medical_records/services/medical_record_service.dart';
import '../../../features/auth/services/auth_service.dart';
import '../../../features/reviews/services/review_service.dart';

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
  final _supabase = Supabase.instance.client;
  final _hospitalService = HospitalService();
  final _appointmentService = AppointmentService();
  final _medicalRecordService = MedicalRecordService();
  final _authService = AuthService();
  final _reviewService = ReviewService();

  bool _isLoading = true;
  Doctor? _doctorInfo;
  List<Appointment> _allAppointments = [];
  List<Appointment> _todayAppointments = [];
  List<MedicalRecord> _recentMedicalRecords = [];
  Map<String, String> _patientNames = {};
  int _totalPatients = 0;
  double _averageRating = 0.0;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDoctorData();
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تأكيد تسجيل الخروج'),
        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _handleLogout(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    // Use a synchronous approach to avoid BuildContext issues
    _supabase.auth.signOut().then((_) {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }).catchError((error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء تسجيل الخروج: $error')),
        );
      }
    });
  }

  Future<void> _loadDoctorData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 1. جلب معلومات الطبيب
      final doctor = await _hospitalService.getDoctorDetails(widget.doctorId);

      // 2. جلب مواعيد الطبيب
      final appointments =
          await _appointmentService.getDoctorAppointments(widget.doctorId);

      // 3. جلب السجلات الطبية التي أضافها الطبيب
      final medicalRecords =
          await _medicalRecordService.getDoctorMedicalRecords(widget.doctorId);

      // 4. جلب متوسط تقييم الطبيب
      final reviews = await _reviewService.getDoctorReviews(widget.doctorId);
      double avgRating = 0;
      if (reviews.isNotEmpty) {
        avgRating = reviews.map((r) => r.rating).reduce((a, b) => a + b) /
            reviews.length;
      }

      // 5. تحديد مواعيد اليوم
      final today = DateTime.now();
      final todayAppointments = appointments
          .where((appointment) =>
              appointment.appointmentDate.year == today.year &&
              appointment.appointmentDate.month == today.month &&
              appointment.appointmentDate.day == today.day)
          .toList();

      // 6. جلب أسماء المرضى
      final patientIds = appointments.map((a) => a.patientId).toSet().toList();
      final patientNames = <String, String>{};
      for (final patientId in patientIds) {
        try {
          final patient = await _authService.getUserProfileById(patientId);
          if (patient != null) {
            patientNames[patientId] = patient.fullName ?? patient.email;
          }
        } catch (e) {
          developer.log('Error fetching patient name: $e');
          patientNames[patientId] = 'مريض';
        }
      }

      // 7. تحديث حالة الشاشة
      if (mounted) {
        setState(() {
          _doctorInfo = doctor;
          _allAppointments = appointments;
          _todayAppointments = todayAppointments;
          _recentMedicalRecords = medicalRecords.take(5).toList();
          _patientNames = patientNames;
          _totalPatients = patientIds.length;
          _averageRating = avgRating;
          _isLoading = false;
        });
      }
    } catch (e) {
      developer.log('Error loading doctor data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء تحميل البيانات: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18.r,
              backgroundColor: Colors.white.withOpacity(0.3),
              child: Icon(
                Icons.medical_services,
                color: Colors.white,
                size: 20.r,
              ),
            ),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'لوحة تحكم الطبيب',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (_doctorInfo != null)
                  Text(
                    _doctorInfo!.nameArabic,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
              ],
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          // زر تسجيل الخروج
          Container(
            margin: EdgeInsets.only(left: 8.w),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout, color: Colors.white, size: 18),
              label: Text(
                'تسجيل الخروج',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                ),
              ),
              onPressed: () => _showLogoutConfirmationDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.8),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              ),
            ),
          ),
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined, color: Colors.white),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: EdgeInsets.all(2.r),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 12.r,
                      minHeight: 12.r,
                    ),
                    child: Text(
                      '2',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
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

                    // الوظائف السريعة
                    _buildQuickActions(),
                    SizedBox(height: 24.h),

                    // مواعيد اليوم
                    _buildSectionTitle(
                      'مواعيد اليوم',
                      Icons.calendar_today,
                      onViewAll: () =>
                          AppNavigator.navigateToDoctorAppointments(
                              context, widget.doctorId),
                    ),
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
                      'أحدث السجلات الطبية',
                      Icons.medical_information,
                      onViewAll: () =>
                          AppNavigator.navigateToDoctorMedicalRecords(
                              context, widget.doctorId),
                    ),
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
    if (_doctorInfo == null) {
      return const SizedBox.shrink();
    }

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
              backgroundImage: _doctorInfo!.profilePhotoUrl != null
                  ? NetworkImage(_doctorInfo!.profilePhotoUrl!)
                  : null,
              child: _doctorInfo!.profilePhotoUrl == null
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
                    _doctorInfo!.nameArabic,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _doctorInfo!.specializationArabic,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 18.r,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        _averageRating > 0
                            ? _averageRating.toStringAsFixed(1)
                            : 'لا يوجد تقييم',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'مواعيد اليوم',
                value: _todayAppointments.length.toString(),
                icon: Icons.calendar_today,
                color: Colors.blue,
                onTap: () => AppNavigator.navigateToDoctorAppointments(
                    context, widget.doctorId),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildStatCard(
                title: 'إجمالي المرضى',
                value: _totalPatients.toString(),
                icon: Icons.people,
                color: Colors.purple,
                onTap: () => AppNavigator.navigateToDoctorPatients(
                    context, widget.doctorId),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'السجلات الطبية',
                value: _recentMedicalRecords.length.toString(),
                icon: Icons.medical_information,
                color: Colors.green,
                onTap: () => AppNavigator.navigateToDoctorMedicalRecords(
                    context, widget.doctorId),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildStatCard(
                title: 'التاريخ',
                value: formattedDate,
                icon: Icons.date_range,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon,
      {VoidCallback? onViewAll}) {
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
        if (onViewAll != null)
          TextButton.icon(
            onPressed: onViewAll,
            icon: const Icon(Icons.arrow_forward, size: 16),
            label: const Text('عرض الكل'),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryGreen,
            ),
          ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('الوظائف السريعة', Icons.dashboard),
        SizedBox(height: 12.h),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16.h,
          crossAxisSpacing: 16.w,
          childAspectRatio: 1.0,
          children: [
            _buildQuickActionItem(
              title: 'المواعيد',
              icon: Icons.calendar_today,
              color: Colors.blue,
              onTap: () => AppNavigator.navigateToDoctorAppointments(
                  context, widget.doctorId),
            ),
            _buildQuickActionItem(
              title: 'المرضى',
              icon: Icons.people,
              color: Colors.purple,
              onTap: () => AppNavigator.navigateToDoctorPatients(
                  context, widget.doctorId),
            ),
            _buildQuickActionItem(
              title: 'السجلات الطبية',
              icon: Icons.medical_information,
              color: Colors.green,
              onTap: () => AppNavigator.navigateToDoctorMedicalRecords(
                  context, widget.doctorId),
            ),
            _buildQuickActionItem(
              title: 'التقييمات',
              icon: Icons.star,
              color: Colors.amber,
              onTap: () {
                // TODO: التنقل إلى شاشة التقييمات
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('سيتم إضافة هذه الميزة قريباً')),
                );
              },
            ),
            _buildQuickActionItem(
              title: 'الملف الشخصي',
              icon: Icons.person,
              color: Colors.teal,
              onTap: () => Navigator.pushNamed(context, '/settings'),
            ),
            _buildQuickActionItem(
              title: 'الإشعارات',
              icon: Icons.notifications,
              color: Colors.red,
              onTap: () => AppNavigator.navigateToNotifications(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionItem({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 28.r,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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

  Widget _buildAppointmentCard(Appointment appointment) {
    // تحويل حالة الموعد إلى العربية
    String statusText;
    Color statusColor;
    switch (appointment.status) {
      case 'Pending':
        statusText = 'قيد الانتظار';
        statusColor = Colors.orange;
        break;
      case 'Confirmed':
        statusText = 'مؤكد';
        statusColor = Colors.blue;
        break;
      case 'Completed':
        statusText = 'مكتمل';
        statusColor = Colors.green;
        break;
      case 'Cancelled':
        statusText = 'ملغي';
        statusColor = Colors.red;
        break;
      default:
        statusText = appointment.status;
        statusColor = Colors.grey;
    }

    // الحصول على اسم المريض
    final patientName = _patientNames[appointment.patientId] ?? 'مريض';

    // تنسيق وقت الموعد
    final appointmentTime =
        appointment.appointmentTime.split(':').take(2).join(':');

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          AppNavigator.navigateToDoctorAppointmentDetails(
            context,
            appointment.id,
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      appointmentTime,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      DateFormat('yyyy/MM/dd', 'ar')
                          .format(appointment.appointmentDate),
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),

              // معلومات المريض
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patientName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    if (appointment.notes != null &&
                        appointment.notes!.isNotEmpty)
                      Text(
                        'ملاحظات: ${appointment.notes}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                  statusText,
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

  Widget _buildMedicalRecordCard(MedicalRecord record) {
    // الحصول على اسم المريض
    final patientName = _patientNames[record.patientId] ?? 'مريض';

    // تنسيق تاريخ السجل
    final formattedDate =
        DateFormat('yyyy/MM/dd', 'ar').format(record.createdAt);

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          AppNavigator.navigateToMedicalRecordDetails(
            context,
            record.id,
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
                      patientName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'التشخيص: ${record.diagnosis}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[800],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                  AppNavigator.navigateToMedicalRecordDetails(
                    context,
                    record.id,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
