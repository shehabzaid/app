import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/hospital.dart';
import '../services/hospital_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/navigation/app_navigator.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _hospitalService = HospitalService();
  final _searchController = TextEditingController();
  bool _isLoading = true;
  String _error = '';
  List<Hospital> _hospitals = [];
  int _currentIndex = 0;
  String? _userName;
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadHospitals();
  }

  Future<void> _loadUserData() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        // بدلاً من التوجيه مباشرة إلى شاشة تسجيل الدخول، نعرض اسم مستخدم افتراضي
        if (mounted) {
          setState(() {
            _userName = "زائر";
          });
        }
        return;
      }

      try {
        final response = await _supabase
            .from('user_profiles')
            .select('email')
            .eq('id', userId)
            .single();

        if (mounted) {
          setState(() {
            _userName = response['email'] as String;
          });
        }
      } catch (profileError) {
        // إذا لم نتمكن من الحصول على الملف الشخصي، نستخدم البريد الإلكتروني من المصادقة
        if (mounted) {
          setState(() {
            _userName = _supabase.auth.currentUser?.email ?? "مستخدم";
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _userName = "زائر";
        });
      }
    }
  }

  Future<void> _loadHospitals() async {
    try {
      setState(() => _isLoading = true);
      final hospitals = await _hospitalService.getAllHospitals();
      setState(() {
        _hospitals = hospitals;
        _error = '';
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      // AppBar
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: const AssetImage('assets/images/logo.png'),
              radius: 20.r,
            ),
            SizedBox(width: 12.w),
            Text(_userName ?? 'جاري التحميل...'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              AppNavigator.navigateToNotifications(context);
            },
          ),
          // عرض زر تسجيل الخروج فقط إذا كان المستخدم مسجل الدخول
          if (_supabase.auth.currentUser != null)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                // حفظ مرجع للسياق قبل العملية غير المتزامنة
                final currentContext = context;

                // تسجيل الخروج
                _supabase.auth.signOut().then((_) {
                  if (mounted) {
                    // تحديث الواجهة بعد تسجيل الخروج
                    setState(() {
                      _userName = "زائر";
                    });

                    // استخدام السياق المحفوظ
                    ScaffoldMessenger.of(currentContext).showSnackBar(
                      const SnackBar(
                        content: Text('تم تسجيل الخروج بنجاح'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                });
              },
            )
          else
            // إذا كان المستخدم غير مسجل، نعرض زر تسجيل الدخول
            IconButton(
              icon: const Icon(Icons.login),
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
            ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Message
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مرحباً، ${_userName ?? ''} 👋',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'كيف يمكننا مساعدتك اليوم؟',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Quick Access Grid
            Padding(
              padding: EdgeInsets.all(16.w),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 16.h,
                crossAxisSpacing: 16.w,
                children: [
                  _buildQuickAccessButton(
                    icon: Icons.local_hospital,
                    label: 'المستشفيات',
                    color: Colors.blue[100]!,
                    onTap: () {
                      AppNavigator.navigateToHospitalDetails(context, '');
                    },
                  ),
                  _buildQuickAccessButton(
                    icon: Icons.medical_services,
                    label: 'الأطباء',
                    color: Colors.green[100]!,
                    onTap: () {
                      AppNavigator.navigateToDoctors(context, null);
                    },
                  ),
                  _buildQuickAccessButton(
                    icon: Icons.calendar_today,
                    label: 'حجوزاتي',
                    color: Colors.orange[100]!,
                    onTap: () {
                      AppNavigator.navigateToMedicalRecords(context);
                    },
                  ),
                  _buildQuickAccessButton(
                    icon: Icons.support_agent,
                    label: 'الدعم',
                    color: Colors.purple[100]!,
                    onTap: () {
                      // Mostrar diálogo de soporte
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('الدعم الفني'),
                          content: const Text(
                              'للتواصل مع الدعم الفني، يرجى الاتصال على الرقم: 920000000'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('إغلاق'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  _buildQuickAccessButton(
                    icon: Icons.settings,
                    label: 'الإعدادات',
                    color: Colors.grey[300]!,
                    onTap: () {
                      AppNavigator.navigateToSettings(context);
                    },
                  ),
                  _buildQuickAccessButton(
                    icon: Icons.folder_shared,
                    label: 'ملفي الطبي',
                    color: Colors.red[100]!,
                    onTap: () {
                      AppNavigator.navigateToMedicalRecords(context);
                    },
                  ),
                ],
              ),
            ),

            // Promotional Banner
            if (true) // TODO: Condition for showing banner
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Card(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Row(
                      children: [
                        Icon(
                          Icons.campaign,
                          color: AppTheme.primaryGreen,
                          size: 32.sp,
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'جديد! 🎉',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'الآن يمكنك حجز موعد في مستشفى الملك فيصل!',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Upcoming Appointments
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'المواعيد القادمة',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Navigate to all appointments
                        },
                        child: const Text('عرض الكل'),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  _buildAppointmentCard(
                    doctorName: 'د. محمد علي',
                    hospital: 'مستشفى الملك فيصل',
                    date: '15 فبراير',
                    time: '09:30 ص',
                    status: 'مؤكد',
                    statusColor: Colors.green,
                  ),
                  SizedBox(height: 8.h),
                  _buildAppointmentCard(
                    doctorName: 'د. سارة أحمد',
                    hospital: 'مستشفى الملك خالد',
                    date: '18 فبراير',
                    time: '11:00 ص',
                    status: 'قيد الانتظار',
                    statusColor: Colors.orange,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index != _currentIndex) {
            setState(() => _currentIndex = index);
            AppNavigator.handlePatientBottomNavigation(context, index);
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryGreen,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_hospital),
            label: 'المستشفيات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'المواعيد',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'حسابي',
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32.sp),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard({
    required String doctorName,
    required String hospital,
    required String date,
    required String time,
    required String status,
    required Color statusColor,
  }) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctorName,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        hospital,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16.sp, color: Colors.grey),
                    SizedBox(width: 4.w),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Icon(Icons.access_time, size: 16.sp, color: Colors.grey),
                    SizedBox(width: 4.w),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Handle appointment details
                  },
                  child: const Text('التفاصيل'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
