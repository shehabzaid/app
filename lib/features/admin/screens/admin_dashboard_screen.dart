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
                    // إحصائيات عامة
                    Text(
                      'نظرة عامة',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _buildStatsGrid(),
                    SizedBox(height: 24.h),

                    // إحصائيات المواعيد
                    Text(
                      'إحصائيات المواعيد',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _buildAppointmentStats(),
                    SizedBox(height: 24.h),

                    // الوصول السريع
                    Text(
                      'الوصول السريع',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _buildQuickAccessGrid(),
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
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 40.w,
              ),
              SizedBox(height: 16.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
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
          onTap: () => _navigateToScreen('/admin/manage-facilities'),
        ),
        _buildQuickAccessButton(
          icon: Icons.category,
          label: 'إدارة الأقسام',
          color: Colors.green[100]!,
          onTap: () => _navigateToScreen('/admin/manage-departments'),
        ),
        _buildQuickAccessButton(
          icon: Icons.medical_services,
          label: 'إدارة الأطباء',
          color: Colors.purple[100]!,
          onTap: () => _navigateToScreen('/admin/manage-doctors'),
        ),
        _buildQuickAccessButton(
          icon: Icons.people,
          label: 'إدارة المستخدمين',
          color: Colors.orange[100]!,
          onTap: () => _navigateToScreen('/admin/manage-users'),
        ),
        _buildQuickAccessButton(
          icon: Icons.calendar_today,
          label: 'إدارة المواعيد',
          color: Colors.red[100]!,
          onTap: () => _navigateToScreen('/admin/manage-appointments'),
        ),
        _buildQuickAccessButton(
          icon: Icons.medical_information,
          label: 'السجلات الطبية',
          color: Colors.teal[100]!,
          onTap: () => _navigateToScreen('/admin/manage-medical-records'),
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
}
