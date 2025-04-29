import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/navigation/app_navigator.dart';
import '../../auth/services/auth_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _authService = AuthService();
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    // TODO: Implement actual API calls to load dashboard data
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    // Mock data for demonstration
    setState(() {
      _stats = {
        'hospitals': 25,
        'doctors': 150,
        'patients': 1200,
        'appointments': {
          'total': 450,
          'today': 35,
          'pending': 120,
          'completed': 330,
        },
      };

      _isLoading = false;
    });
  }

  Future<void> _logout() async {
    setState(() => _isLoading = true);

    try {
      await _authService.adminLogout();

      if (mounted) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/admin-login', (route) => false);
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

  void _navigateToScreen(String route) {
    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم المدير'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () =>
                AppNavigator.navigateToManageNotifications(context),
            tooltip: 'الإشعارات',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'تسجيل الخروج',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // شريط البحث السريع
                    _buildSearchBar(),
                    SizedBox(height: 24.h),

                    // المهام السريعة
                    _buildQuickTasks(),
                    SizedBox(height: 24.h),

                    // إحصائيات عامة
                    Row(
                      children: [
                        Icon(Icons.insights,
                            color: AppTheme.primaryGreen, size: 24.w),
                        SizedBox(width: 8.w),
                        Text(
                          'نظرة عامة',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    _buildStatsGrid(),
                    SizedBox(height: 24.h),

                    // إحصائيات المواعيد
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            color: AppTheme.primaryGreen, size: 24.w),
                        SizedBox(width: 8.w),
                        Text(
                          'إحصائيات المواعيد',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    _buildAppointmentStats(),
                    SizedBox(height: 24.h),

                    // الوصول السريع
                    Row(
                      children: [
                        Icon(Icons.grid_view,
                            color: AppTheme.primaryGreen, size: 24.w),
                        SizedBox(width: 8.w),
                        Text(
                          'الوصول السريع',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    _buildQuickAccessGrid(),
                    SizedBox(height: 24.h),

                    // آخر النشاطات
                    Row(
                      children: [
                        Icon(Icons.history,
                            color: AppTheme.primaryGreen, size: 24.w),
                        SizedBox(width: 8.w),
                        Text(
                          'آخر النشاطات',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    _buildRecentActivities(),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index != _currentIndex) {
            setState(() => _currentIndex = index);
            AppNavigator.handleAdminBottomNavigation(context, index);
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
            icon: Icon(Icons.local_hospital),
            label: 'المنشآت',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'المستخدمين',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'الإعدادات',
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16.h,
      crossAxisSpacing: 16.w,
      children: [
        _buildStatCard(
          title: 'المستشفيات',
          value: _stats['hospitals'].toString(),
          icon: Icons.local_hospital,
          color: Colors.blue,
          onTap: () => _navigateToScreen('/admin/hospitals'),
        ),
        _buildStatCard(
          title: 'الأطباء',
          value: _stats['doctors'].toString(),
          icon: Icons.medical_services,
          color: Colors.green,
          onTap: () => _navigateToScreen('/admin/doctors'),
        ),
        _buildStatCard(
          title: 'المرضى',
          value: _stats['patients'].toString(),
          icon: Icons.people,
          color: Colors.orange,
          onTap: () => _navigateToScreen('/admin/patients'),
        ),
        _buildStatCard(
          title: 'المواعيد',
          value: _stats['appointments']['total'].toString(),
          icon: Icons.calendar_today,
          color: Colors.purple,
          onTap: () => _navigateToScreen('/admin/appointments'),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                color.withOpacity(0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 28.w,
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_forward, color: color, size: 16.w),
                        SizedBox(width: 4.w),
                        Text(
                          'التفاصيل',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Padding(
                    padding: EdgeInsets.only(bottom: 4.h),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_upward,
                              color: Colors.green, size: 12.w),
                          SizedBox(width: 2.w),
                          Text(
                            '12%',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentStats() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildAppointmentStatItem(
                  title: 'اليوم',
                  value: _stats['appointments']['today'].toString(),
                  color: Colors.blue,
                ),
                _buildAppointmentStatItem(
                  title: 'قيد الانتظار',
                  value: _stats['appointments']['pending'].toString(),
                  color: Colors.orange,
                ),
                _buildAppointmentStatItem(
                  title: 'مكتملة',
                  value: _stats['appointments']['completed'].toString(),
                  color: Colors.green,
                ),
              ],
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () => _navigateToScreen('/admin/appointments'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 12.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('عرض جميع المواعيد'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentStatItem({
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 60.w,
          height: 60.w,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAccessGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 16.h,
      crossAxisSpacing: 16.w,
      children: [
        _buildQuickAccessButton(
          icon: Icons.local_hospital,
          label: 'إدارة المنشآت',
          color: Colors.blue[100]!,
          onTap: () => AppNavigator.navigateToManageFacilities(context),
        ),
        _buildQuickAccessButton(
          icon: Icons.category,
          label: 'إدارة الأقسام',
          color: Colors.green[100]!,
          onTap: () => AppNavigator.navigateToManageDepartments(context),
        ),
        _buildQuickAccessButton(
          icon: Icons.medical_services,
          label: 'إدارة الأطباء',
          color: Colors.purple[100]!,
          onTap: () => AppNavigator.navigateToManageDoctors(context),
        ),
        _buildQuickAccessButton(
          icon: Icons.people,
          label: 'إدارة المستخدمين',
          color: Colors.orange[100]!,
          onTap: () => AppNavigator.navigateToManageUsers(context),
        ),
        _buildQuickAccessButton(
          icon: Icons.calendar_today,
          label: 'إدارة المواعيد',
          color: Colors.red[100]!,
          onTap: () => AppNavigator.navigateToManageAppointments(context),
        ),
        _buildQuickAccessButton(
          icon: Icons.notifications,
          label: 'إدارة الإشعارات',
          color: Colors.teal[100]!,
          onTap: () => AppNavigator.navigateToManageNotifications(context),
        ),
        _buildQuickAccessButton(
          icon: Icons.campaign,
          label: 'إدارة الإعلانات',
          color: Colors.amber[100]!,
          onTap: () => AppNavigator.navigateToAdvertisements(context),
        ),
      ],
    );
  }

  Widget _buildQuickAccessButton({
    required IconData icon,
    required String label,
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
        child: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32.w,
                color: color
                    .withRed(color.red - 40)
                    .withGreen(color.green - 40)
                    .withBlue(color.blue - 40),
              ),
              SizedBox(height: 8.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // شريط البحث السريع
  Widget _buildSearchBar() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.grey[600]),
            SizedBox(width: 12.w),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'بحث سريع...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey[400]),
                ),
                onSubmitted: (value) {
                  // TODO: تنفيذ البحث
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('جاري البحث عن: $value')),
                  );
                },
              ),
            ),
            IconButton(
              icon: Icon(Icons.tune, color: AppTheme.primaryGreen),
              onPressed: () {
                // TODO: فتح خيارات البحث المتقدم
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('خيارات البحث المتقدم')),
                );
              },
              tooltip: 'خيارات متقدمة',
            ),
          ],
        ),
      ),
    );
  }

  // المهام السريعة
  Widget _buildQuickTasks() {
    return Card(
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
              children: [
                Icon(Icons.flash_on, color: Colors.amber, size: 24.w),
                SizedBox(width: 8.w),
                Text(
                  'المهام السريعة',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildQuickTaskButton(
                    icon: Icons.person_add,
                    label: 'إضافة مستخدم',
                    color: Colors.blue,
                    onTap: () => AppNavigator.navigateToManageUsers(context),
                  ),
                  SizedBox(width: 12.w),
                  _buildQuickTaskButton(
                    icon: Icons.add_business,
                    label: 'إضافة منشأة',
                    color: Colors.green,
                    onTap: () =>
                        AppNavigator.navigateToManageFacilities(context),
                  ),
                  SizedBox(width: 12.w),
                  _buildQuickTaskButton(
                    icon: Icons.medical_services,
                    label: 'ربط طبيب',
                    color: Colors.purple,
                    onTap: () => AppNavigator.navigateToLinkDoctorUser(context),
                  ),
                  SizedBox(width: 12.w),
                  _buildQuickTaskButton(
                    icon: Icons.campaign,
                    label: 'إضافة إعلان',
                    color: Colors.orange,
                    onTap: () => AppNavigator.navigateToAdvertisements(context),
                  ),
                  SizedBox(width: 12.w),
                  _buildQuickTaskButton(
                    icon: Icons.notifications_active,
                    label: 'إرسال إشعار',
                    color: Colors.red,
                    onTap: () =>
                        AppNavigator.navigateToManageNotifications(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // زر المهام السريعة
  Widget _buildQuickTaskButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24.w),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // آخر النشاطات
  Widget _buildRecentActivities() {
    // بيانات وهمية للنشاطات الأخيرة
    final activities = [
      {
        'icon': Icons.person_add,
        'title': 'تم إضافة مستخدم جديد',
        'description': 'تم إضافة الطبيب أحمد محمد',
        'time': 'منذ 10 دقائق',
        'color': Colors.blue,
      },
      {
        'icon': Icons.edit,
        'title': 'تم تعديل بيانات منشأة',
        'description': 'تم تحديث بيانات مستشفى الملك فهد',
        'time': 'منذ 30 دقيقة',
        'color': Colors.green,
      },
      {
        'icon': Icons.calendar_today,
        'title': 'تم تأكيد موعد',
        'description': 'تم تأكيد موعد المريض خالد مع د. سارة',
        'time': 'منذ ساعة',
        'color': Colors.purple,
      },
      {
        'icon': Icons.campaign,
        'title': 'تم إضافة إعلان جديد',
        'description': 'تم إضافة إعلان عن خدمات جديدة',
        'time': 'منذ 3 ساعات',
        'color': Colors.orange,
      },
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            ...activities.map((activity) => _buildActivityItem(
                  icon: activity['icon'] as IconData,
                  title: activity['title'] as String,
                  description: activity['description'] as String,
                  time: activity['time'] as String,
                  color: activity['color'] as Color,
                )),
            SizedBox(height: 8.h),
            TextButton(
              onPressed: () {
                // TODO: عرض جميع النشاطات
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('عرض جميع النشاطات')),
                );
              },
              child: Text(
                'عرض الكل',
                style: TextStyle(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // عنصر النشاط
  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String description,
    required String time,
    required Color color,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20.w),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
