import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/intro_page_model.dart';
import '../../../core/theme/app_theme.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // تخزين حالة عرض الإنترو
  Future<void> _setIntroShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('intro_shown', true);
  }

  // الانتقال إلى شاشة تسجيل الدخول
  void _navigateToLogin() {
    _setIntroShown();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // صفحات الإنترو
          PageView.builder(
            controller: _pageController,
            itemCount: introPages.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final page = introPages[index];

              return Container(
                color: page.backgroundColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // صورة الإنترو
                    if (index == 0) // الصفحة الأولى (Splash)
                      Container(
                        width: double.infinity,
                        color: page.backgroundColor,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              page.imagePath,
                              width: 120.w,
                              height: 120.w,
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
                      )
                    else // باقي الصفحات
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Column(
                          children: [
                            // شعار التطبيق في الأعلى
                            Padding(
                              padding: EdgeInsets.only(top: 60.h, bottom: 20.h),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.favorite,
                                    color: AppTheme.primaryBlue,
                                    size: 24.w,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Medical App',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // عنوان الصفحة
                            Text(
                              page.title,
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.bold,
                                color: page.textColor,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            SizedBox(height: 16.h),

                            // وصف الصفحة
                            Text(
                              page.description,
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: page.textColor,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            SizedBox(height: 40.h),

                            // صورة توضيحية
                            Expanded(
                              child: Image.asset(
                                page.imagePath,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.image_not_supported,
                                    size: 100.w,
                                    color: Colors.grey,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          ),

          // أزرار التنقل في الأسفل
          Positioned(
            bottom: 50.h,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // مؤشرات الصفحات
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    introPages.length,
                    (index) => Container(
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index
                            ? AppTheme.primaryBlue
                            : Colors.grey.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 30.h),

                // أزرار التالي والتخطي
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // زر التخطي
                      TextButton(
                        onPressed: _navigateToLogin,
                        child: Text(
                          'تخطي',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: _currentPage == 0
                                ? Colors.white
                                : AppTheme.primaryBlue,
                          ),
                        ),
                      ),

                      // زر التالي
                      TextButton(
                        onPressed: () {
                          if (_currentPage < introPages.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            _navigateToLogin();
                          }
                        },
                        child: Text(
                          _currentPage < introPages.length - 1
                              ? 'التالي'
                              : 'ابدأ',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: _currentPage == 0
                                ? Colors.white
                                : AppTheme.primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
