import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/navigation/app_navigator.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // التحقق مما إذا كان المستخدم قد شاهد شاشات الإنترو من قبل
    final prefs = await SharedPreferences.getInstance();
    final introShown = prefs.getBool('intro_shown') ?? false;

    // التحقق من وجود جلسة مستخدم نشطة
    final session = await _authService.getSession();

    if (!mounted) return;

    if (session != null) {
      // إذا كان هناك جلسة نشطة، انتقل إلى الشاشة المناسبة حسب نوع المستخدم
      String userType = 'patient';
      if (session['isAdmin'] == true) {
        userType = 'admin';
      } else if (session['isDoctor'] == true) {
        userType = 'doctor';
      }

      AppNavigator.navigateToHome(context, userType);
    } else if (introShown) {
      // إذا كان المستخدم قد شاهد شاشات الإنترو من قبل، انتقل مباشرة إلى شاشة تسجيل الدخول
      Navigator.of(context).pushReplacementNamed('/login');
    } else {
      // إذا كان المستخدم لم يشاهد شاشات الإنترو من قبل، انتقل إلى شاشة الإنترو
      Navigator.of(context).pushReplacementNamed('/intro');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryGreen,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/Logo.png',
              width: 500.w,
              height: 500.w,
              color: Colors.white,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.health_and_safety,
                  size: 120.w,
                  color: Colors.white,
                );
              },
            ),
            SizedBox(height: 24.h),
            Text(
              'صحتي بلس',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
