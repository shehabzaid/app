import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/config/supabase_config.dart';
import 'core/config/environment_config.dart'
    show EnvironmentConfig, Environment;
import 'core/theme/app_theme.dart';
import 'core/navigation/app_router.dart';
import 'core/utils/responsive_helper.dart';
import 'features/hospitals/screens/home_screen.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // تعيين البيئة الحالية (يمكن تغييرها حسب الحاجة)
    // يمكن استخدام متغيرات البيئة لتحديد البيئة الحالية
    const envName =
        String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');

    switch (envName) {
      case 'production':
        EnvironmentConfig.setEnvironment(Environment.production);
        break;
      case 'staging':
        EnvironmentConfig.setEnvironment(Environment.staging);
        break;
      default:
        EnvironmentConfig.setEnvironment(Environment.development);
    }

    debugPrint('البيئة الحالية: $envName');
    debugPrint('عنوان Supabase: ${SupabaseConfig.url}');

    // محاولة الاتصال بخدمة Supabase
    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
        debug: true,
      );
      debugPrint('تم الاتصال بخدمة Supabase بنجاح');
    } catch (supabaseError) {
      // في حالة فشل الاتصال بخدمة Supabase، نقوم بتسجيل الخطأ فقط ونستمر في تشغيل التطبيق
      debugPrint('فشل الاتصال بخدمة Supabase: $supabaseError');
      debugPrint('سيتم تشغيل التطبيق في وضع عدم الاتصال');
    }

    // تشغيل التطبيق بغض النظر عن نجاح الاتصال بخدمة Supabase
    runApp(const MyApp());
  } catch (e) {
    // استخدام debugPrint بدلاً من print
    debugPrint('Error initializing app: $e');
    // يمكنك هنا عرض واجهة خطأ بدلاً من الشاشة البيضاء
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('حدث خطأ في تهيئة التطبيق: $e'),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      // تحديد حجم التصميم بناءً على عرض الشاشة
      Size designSize;
      if (constraints.maxWidth < 650) {
        // الهاتف المحمول
        designSize = const Size(375, 812);
      } else if (constraints.maxWidth < 1100) {
        // الجهاز اللوحي
        designSize = const Size(768, 1024);
      } else {
        // سطح المكتب
        designSize = const Size(1440, 900);
      }

      return ScreenUtilInit(
        designSize: designSize,
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            title: 'منصة صحتي بلس',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ar', 'SA'),
              Locale('en', 'US'),
            ],
            locale: const Locale('ar', 'SA'),
            builder: (context, child) {
              // تطبيق EasyLoading
              child = EasyLoading.init()(context, child);

              // تطبيق التوافق مع أحجام الشاشات المختلفة
              return MediaQuery(
                // تعديل حجم الخط بناءً على حجم الشاشة
                data: MediaQuery.of(context).copyWith(
                  textScaler: MediaQuery.of(context).size.width < 650
                      ? const TextScaler.linear(1.0)
                      : MediaQuery.of(context).size.width < 1100
                          ? const TextScaler.linear(1.1)
                          : const TextScaler.linear(1.2),
                ),
                child: child,
              );
            },
            home: const HomeScreen(),
            onGenerateRoute: AppRouter.generateRoute,
          );
        },
      );
    });
  }
}
