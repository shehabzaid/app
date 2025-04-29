import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/navigation/app_navigator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;
import '../services/hospital_service.dart';
import '../models/hospital.dart';
import '../../../features/advertisements/services/advertisement_service.dart';
import '../../../features/advertisements/models/advertisement.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final HospitalService _hospitalService = HospitalService();
  final AdvertisementService _adService = AdvertisementService();

  String? _userName = 'زائر';
  int _currentIndex = 0;
  bool _isLoading = true;

  List<Advertisement> _advertisements = [];
  List<Hospital> _hospitals = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load user info
      await _loadUser();

      // Load advertisements
      _advertisements = await _adService.getActiveAdvertisements();

      // Load hospitals
      _hospitals = await _hospitalService.getAllHospitals(forceRefresh: true);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      developer.log('Error loading data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadUser() async {
    final user = _supabase.auth.currentUser;
    if (user != null && mounted) {
      setState(() {
        _userName = user.email ?? 'مستخدم';
      });
    }
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

  void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الدخول مطلوب'),
        content: const Text(
            'يجب تسجيل الدخول للوصول إلى هذه الخدمة. هل تريد تسجيل الدخول الآن؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
            ),
            child: const Text('تسجيل الدخول'),
          ),
        ],
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = _supabase.auth.currentUser != null;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        centerTitle: false,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18.r,
              backgroundColor: Colors.white.withOpacity(0.3),
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 22.r,
              ),
            ),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'مرحباً،',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                Text(
                  _userName ?? 'زائر',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // زر تسجيل الدخول للزائر
          if (!isLoggedIn)
            Container(
              margin: EdgeInsets.only(left: 8.w),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.login,
                    color: AppTheme.primaryGreen, size: 18),
                label: Text(
                  'تسجيل الدخول',
                  style: TextStyle(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                ),
              ),
            ),
          // زر تسجيل الخروج للمستخدمين المسجلين
          if (isLoggedIn)
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
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
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
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildAdsSlider(),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: _buildQuickAccess(),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: _buildFacilitiesSection(),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() => _currentIndex = index);
              AppNavigator.handlePatientBottomNavigation(context, index);
            },
            selectedItemColor: AppTheme.primaryGreen,
            unselectedItemColor: Colors.grey[400],
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            selectedLabelStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12.sp,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 12.sp,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'الرئيسية',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search_outlined),
                activeIcon: Icon(Icons.search),
                label: 'البحث',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today_outlined),
                activeIcon: Icon(Icons.calendar_today),
                label: 'المواعيد',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'حسابي',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdsSlider() {
    // If no ads available, show placeholder
    if (_advertisements.isEmpty) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryGreen.withOpacity(0.1),
              AppTheme.primaryGreen.withOpacity(0.2),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        height: 180.h,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.campaign_outlined,
                size: 48.r,
                color: AppTheme.primaryGreen.withOpacity(0.7),
              ),
              SizedBox(height: 12.h),
              Text(
                'لا توجد إعلانات متاحة',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.only(top: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Icon(
                  Icons.campaign_outlined,
                  size: 20.r,
                  color: AppTheme.primaryGreen,
                ),
                SizedBox(width: 8.w),
                Text(
                  'أحدث العروض والإعلانات',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          CarouselSlider(
            options: CarouselOptions(
              height: 180.h,
              autoPlay: true,
              enlargeCenterPage: true,
              viewportFraction: 0.9,
              autoPlayInterval: const Duration(seconds: 5),
              onPageChanged: (index, reason) {
                // يمكن إضافة مؤشر للصفحة الحالية هنا
              },
            ),
            items: _advertisements.map((ad) {
              return Builder(
                builder: (context) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 5.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.r),
                    child: Stack(
                      children: [
                        Image.network(
                          ad.imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            color: Colors.grey[300],
                            child: Center(
                              child: Icon(
                                Icons.error_outline,
                                size: 40.r,
                                color: Colors.grey[500],
                              ),
                            ),
                          ),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey[200],
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                            );
                          },
                        ),
                        if (ad.title.isNotEmpty)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 12.h,
                                horizontal: 16.w,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7),
                                  ],
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ad.title,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                  if (ad.description != null &&
                                      ad.description!.isNotEmpty)
                                    SizedBox(height: 4.h),
                                  if (ad.description != null &&
                                      ad.description!.isNotEmpty)
                                    Text(
                                      ad.description!,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 12.sp,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        Positioned(
                          top: 12.h,
                          right: 12.w,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              'عرض خاص',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 16.h),
          // مؤشرات الصفحات
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _advertisements.asMap().entries.map((entry) {
              return Container(
                width: 8.w,
                height: 8.h,
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryGreen.withOpacity(
                    0.3,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccess() {
    final bool isLoggedIn = _supabase.auth.currentUser != null;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.grid_view_rounded,
                size: 20.r,
                color: AppTheme.primaryGreen,
              ),
              SizedBox(width: 8.w),
              Text(
                'الخدمات السريعة',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // إذا كان المستخدم غير مسجل، نعرض زر تسجيل الدخول بشكل بارز
          if (!isLoggedIn)
            Container(
              margin: EdgeInsets.only(bottom: 16.h),
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.login),
                label: Text(
                  'تسجيل الدخول للوصول إلى كافة الخدمات',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16.h,
            crossAxisSpacing: 16.w,
            childAspectRatio: 1.4,
            children: [
              _quickButton(
                icon: Icons.medical_services,
                label: 'الأطباء',
                description: 'ابحث عن أطباء',
                color: Colors.blue,
                onTap: () => AppNavigator.navigateToDoctors(context, null),
              ),
              _quickButton(
                icon: Icons.local_hospital,
                label: 'المستشفيات',
                description: 'تصفح المنشآت الصحية',
                color: Colors.green,
                onTap: () => AppNavigator.navigateToHospitals(context),
              ),
              _quickButton(
                icon: Icons.folder_shared,
                label: 'ملفي الطبي',
                description: 'سجلاتك الطبية',
                color: Colors.purple,
                onTap: () {
                  if (isLoggedIn) {
                    AppNavigator.navigateToMedicalRecords(context);
                  } else {
                    _showLoginRequiredDialog(context);
                  }
                },
              ),
              _quickButton(
                icon: Icons.calendar_today,
                label: 'حجوزاتي',
                description: 'إدارة المواعيد',
                color: Colors.orange,
                onTap: () {
                  if (isLoggedIn) {
                    Navigator.pushNamed(context, '/my-appointments');
                  } else {
                    _showLoginRequiredDialog(context);
                  }
                },
              ),
            ],
          ),
          SizedBox(height: 8.h),
          // أزرار إضافية
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _quickActionButton(
                  icon: Icons.add_circle_outline,
                  label: 'حجز موعد جديد',
                  color: AppTheme.primaryGreen,
                  onTap: () {
                    // التنقل إلى صفحة حجز موعد جديد
                    AppNavigator.navigateToHospitals(context);
                  },
                ),
                SizedBox(width: 12.w),
                _quickActionButton(
                  icon: Icons.star_outline,
                  label: 'تقييم طبيب',
                  color: Colors.amber,
                  onTap: () {
                    // التنقل إلى صفحة تقييم الأطباء
                    AppNavigator.navigateToDoctors(context, null);
                  },
                ),
                SizedBox(width: 12.w),
                _quickActionButton(
                  icon: Icons.help_outline,
                  label: 'المساعدة',
                  color: Colors.blue,
                  onTap: () {
                    // عرض صفحة المساعدة
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('سيتم إضافة صفحة المساعدة قريباً')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickButton({
    required IconData icon,
    required String label,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
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
                size: 28.r,
                color: color,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              description,
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20.r,
              color: color,
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12.sp,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFacilitiesSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_hospital,
                size: 20.r,
                color: AppTheme.primaryGreen,
              ),
              SizedBox(width: 8.w),
              Text(
                'المنشآت الصحية',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => AppNavigator.navigateToHospitals(context),
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('عرض الجميع'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primaryGreen,
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          if (_hospitals.isEmpty)
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.local_hospital_outlined,
                    size: 48.r,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'لا توجد منشآت صحية متاحة حالياً',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            Column(
              children: [
                ..._hospitals.take(3).map((hospital) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: _facilityCard(hospital),
                  );
                }).toList(),
                // عرض المزيد من المنشآت
                if (_hospitals.length > 3)
                  InkWell(
                    onTap: () => AppNavigator.navigateToHospitals(context),
                    borderRadius: BorderRadius.circular(16.r),
                    child: Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: AppTheme.primaryGreen.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'عرض ${_hospitals.length - 3} منشآت أخرى',
                            style: TextStyle(
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Icon(
                            Icons.arrow_forward,
                            size: 16.r,
                            color: AppTheme.primaryGreen,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          SizedBox(height: 24.h),
          // إضافة قسم الأطباء الموصى بهم
          _buildRecommendedDoctors(),
        ],
      ),
    );
  }

  Widget _facilityCard(Hospital hospital) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () =>
            AppNavigator.navigateToHospitalDetails(context, hospital.id),
        borderRadius: BorderRadius.circular(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة المنشأة
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
              child: Image.network(
                hospital.imageUrl ?? 'https://via.placeholder.com/150',
                height: 120.h,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 120.h,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.local_hospital,
                    size: 40.r,
                    color: Colors.grey[400],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          hospital.nameArabic,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 14.r,
                              color: Colors.amber,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '4.5',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12.sp,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16.r,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          '${hospital.city}، ${hospital.region}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.phone,
                        size: 16.r,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        hospital.phone ?? 'غير متوفر',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              AppNavigator.navigateToHospitalDetails(
                                  context, hospital.id),
                          icon: Icon(
                            Icons.info_outline,
                            size: 16.r,
                          ),
                          label: const Text('التفاصيل'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryGreen,
                            side:
                                const BorderSide(color: AppTheme.primaryGreen),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // التنقل إلى صفحة حجز موعد
                            AppNavigator.navigateToHospitalDetails(
                                context, hospital.id);
                          },
                          icon: Icon(
                            Icons.calendar_today,
                            size: 16.r,
                          ),
                          label: const Text('حجز'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
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

  // قسم الأطباء الموصى بهم
  Widget _buildRecommendedDoctors() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.medical_services,
              size: 20.r,
              color: AppTheme.primaryGreen,
            ),
            SizedBox(width: 8.w),
            Text(
              'أطباء موصى بهم',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => AppNavigator.navigateToDoctors(context, null),
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('عرض الجميع'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryGreen,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        SizedBox(
          height: 200.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5, // عدد وهمي للأطباء
            itemBuilder: (context, index) {
              return _doctorCard(index);
            },
          ),
        ),
      ],
    );
  }

  // بطاقة الطبيب
  Widget _doctorCard(int index) {
    // بيانات وهمية للأطباء
    final List<Map<String, dynamic>> doctors = [
      {
        'name': 'د. أحمد محمد',
        'specialty': 'طب عام',
        'rating': 4.8,
        'image': 'https://via.placeholder.com/150',
      },
      {
        'name': 'د. سارة خالد',
        'specialty': 'أمراض قلب',
        'rating': 4.9,
        'image': 'https://via.placeholder.com/150',
      },
      {
        'name': 'د. محمد علي',
        'specialty': 'جراحة عامة',
        'rating': 4.7,
        'image': 'https://via.placeholder.com/150',
      },
      {
        'name': 'د. نورة سعد',
        'specialty': 'أطفال',
        'rating': 4.6,
        'image': 'https://via.placeholder.com/150',
      },
      {
        'name': 'د. فهد عبدالله',
        'specialty': 'عظام',
        'rating': 4.5,
        'image': 'https://via.placeholder.com/150',
      },
    ];

    final doctor = doctors[index];

    return Container(
      width: 160.w,
      margin: EdgeInsets.only(right: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => AppNavigator.navigateToDoctors(context, null),
        borderRadius: BorderRadius.circular(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 16.h),
            CircleAvatar(
              radius: 40.r,
              backgroundImage: NetworkImage(doctor['image']),
              backgroundColor: Colors.grey[200],
            ),
            SizedBox(height: 12.h),
            Text(
              doctor['name'],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            Text(
              doctor['specialty'],
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.star,
                  size: 16.r,
                  color: Colors.amber,
                ),
                SizedBox(width: 4.w),
                Text(
                  doctor['rating'].toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
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
