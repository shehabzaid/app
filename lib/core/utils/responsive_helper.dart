import 'package:flutter/material.dart';

/// مساعد للتعامل مع الشاشات المختلفة وجعل التطبيق متجاوبًا
class ResponsiveHelper {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 650;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 650 &&
      MediaQuery.of(context).size.width < 1100;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  /// الحصول على عرض الشاشة
  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  /// الحصول على ارتفاع الشاشة
  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  /// الحصول على حجم الخط المناسب بناءً على عرض الشاشة
  static double getFontSize(BuildContext context, double baseFontSize) {
    if (isMobile(context)) {
      return baseFontSize;
    } else if (isTablet(context)) {
      return baseFontSize * 1.2;
    } else {
      return baseFontSize * 1.5;
    }
  }

  /// الحصول على حجم الأيقونة المناسب بناءً على عرض الشاشة
  static double getIconSize(BuildContext context, double baseIconSize) {
    if (isMobile(context)) {
      return baseIconSize;
    } else if (isTablet(context)) {
      return baseIconSize * 1.2;
    } else {
      return baseIconSize * 1.5;
    }
  }

  /// الحصول على عدد الأعمدة المناسب للشبكة بناءً على عرض الشاشة
  static int getCrossAxisCount(BuildContext context) {
    if (isMobile(context)) {
      return 2;
    } else if (isTablet(context)) {
      return 3;
    } else {
      return 4;
    }
  }

  /// الحصول على نسبة العرض إلى الارتفاع المناسبة للبطاقات بناءً على عرض الشاشة
  static double getAspectRatio(BuildContext context) {
    if (isMobile(context)) {
      return 1.2;
    } else if (isTablet(context)) {
      return 1.3;
    } else {
      return 1.4;
    }
  }

  /// الحصول على عرض الحاوية المناسب بناءً على عرض الشاشة
  static double getContainerWidth(BuildContext context) {
    if (isMobile(context)) {
      return screenWidth(context) * 0.9;
    } else if (isTablet(context)) {
      return screenWidth(context) * 0.8;
    } else {
      return screenWidth(context) * 0.7;
    }
  }

  /// الحصول على حجم الهامش المناسب بناءً على عرض الشاشة
  static double getPadding(BuildContext context, double basePadding) {
    if (isMobile(context)) {
      return basePadding;
    } else if (isTablet(context)) {
      return basePadding * 1.5;
    } else {
      return basePadding * 2;
    }
  }

  /// إنشاء تخطيط متجاوب
  static Widget buildResponsiveLayout({
    required BuildContext context,
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    if (isDesktop(context) && desktop != null) {
      return desktop;
    } else if (isTablet(context) && tablet != null) {
      return tablet;
    } else {
      return mobile;
    }
  }
}
