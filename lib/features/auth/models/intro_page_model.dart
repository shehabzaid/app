import 'package:flutter/material.dart';

class IntroPageModel {
  final String title;
  final String description;
  final String imagePath;
  final Color backgroundColor;
  final Color textColor;

  IntroPageModel({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.backgroundColor,
    required this.textColor,
  });
}

final List<IntroPageModel> introPages = [
  // صفحة الإنترو الأولى
  IntroPageModel(
    title: 'صحتي بلس',
    description: 'تطبيق المواعيد الطبية الموثوق',
    imagePath: 'assets/images/Logo.png', // استخدم الشعار المتوفر حاليًا
    backgroundColor: const Color(0xFF3949AB), // لون أزرق داكن
    textColor: Colors.white,
  ),
  // صفحة الإنترو الثانية
  IntroPageModel(
    title: 'صحتي بلس',
    description: 'تطبيق المواعيد الطبية الموثوق',
    imagePath: 'assets/images/Logo.png', // استخدم الشعار المتوفر حاليًا
    backgroundColor: Colors.white,
    textColor: Colors.black,
  ),
  // صفحة الإنترو الثالثة
  IntroPageModel(
    title: 'Storage your Medical Records',
    description: 'احفظ سجلاتك الطبية بأمان وسهولة',
    imagePath: 'assets/images/Logo.png', // استخدم الشعار المتوفر حاليًا
    backgroundColor: Colors.white,
    textColor: Colors.black,
  ),
  // صفحة الإنترو الرابعة
  IntroPageModel(
    title: 'Discuss in the Forum',
    description: 'شارك في منتدى النقاش الطبي',
    imagePath: 'assets/images/Logo.png', // استخدم الشعار المتوفر حاليًا
    backgroundColor: Colors.white,
    textColor: Colors.black,
  ),
];
