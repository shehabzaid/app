import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_flutter;
import 'dart:developer' as developer;
import '../../../core/theme/app_theme.dart';
import '../../../core/navigation/app_navigator.dart';
import '../../../core/config/supabase_config.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  List<User> _users = [];
  User? _selectedUser;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final users = await _authService.getAllUsers();

      if (mounted) {
        setState(() {
          _users = users;
          _isLoading = false;
        });

        // Show a message if no users were found
        if (users.isEmpty) {
          // عرض رسالة مع خيار إنشاء مستخدم تجريبي
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('لا يوجد مستخدمين'),
              content: const Text(
                  'لم يتم العثور على أي مستخدمين في قاعدة البيانات. هل ترغب في إنشاء مستخدم تجريبي؟'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _createDemoUser();
                  },
                  child: const Text('إنشاء مستخدم تجريبي'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ في تحميل قائمة المستخدمين: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  /// إنشاء مستخدم تجريبي
  Future<void> _createDemoUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final demoUser = await _authService.createDemoUser();

      if (mounted) {
        if (demoUser != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إنشاء مستخدم تجريبي بنجاح'),
              backgroundColor: Colors.green,
            ),
          );

          // تحديث قائمة المستخدمين
          _loadUsers();
        } else {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('فشل في إنشاء مستخدم تجريبي'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ في إنشاء مستخدم تجريبي: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  /// إنشاء جداول المستخدمين
  Future<void> _createTables() async {
    setState(() => _isLoading = true);

    try {
      // إنشاء الجداول المطلوبة
      final success = await _authService.createUserTables();

      // إعادة تحميل المستخدمين
      final users = await _authService.getAllUsers();

      if (!mounted) return;

      setState(() {
        _users = users;
        if (users.isNotEmpty) {
          _selectedUser = users.first;
        }
      });

      final message =
          success ? 'تم إنشاء الجداول بنجاح' : 'تم محاولة إنشاء الجداول';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: success ? AppTheme.primaryGreen : Colors.orange,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في إنشاء الجداول: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() => _isLoading = true);
      try {
        final password = _formKey.currentState!.value['password'] as String;

        if (_selectedUser == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('الرجاء اختيار المستخدم'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
          return;
        }

        // التحقق إذا كان المستخدم المحدد هو المستخدم التجريبي
        if (_selectedUser!.id == 'demo-user-id' ||
            _selectedUser!.email == 'demo.user@example.com') {
          // تسجيل الدخول كمستخدم تجريبي بدون التحقق من كلمة المرور
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم تسجيل الدخول كمستخدم تجريبي'),
                backgroundColor: Colors.green,
              ),
            );

            // الانتقال إلى الشاشة الرئيسية كمريض
            AppNavigator.navigateToHome(context, 'patient');
          }
          return;
        }

        // تسجيل الدخول للمستخدمين العاديين
        final user = await _authService.login(
          email: _selectedUser!.email,
          password: password,
        );

        if (user != null) {
          if (mounted) {
            // تحديد نوع المستخدم والانتقال إلى الشاشة المناسبة
            String userType = 'patient';
            if (user['isAdmin'] == true) {
              userType = 'admin';
            } else if (user['isDoctor'] == true) {
              userType = 'doctor';
            }

            AppNavigator.navigateToHome(context, userType);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('كلمة المرور غير صحيحة'),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          String errorMessage = 'حدث خطأ في تسجيل الدخول';
          if (e.toString().contains('Invalid login credentials')) {
            errorMessage = 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
          } else if (e.toString().contains('Email not confirmed')) {
            errorMessage = 'يرجى تأكيد البريد الإلكتروني';
          } else if (e.toString().contains('relation') &&
              e.toString().contains('does not exist')) {
            errorMessage = 'خطأ في قاعدة البيانات: الجدول غير موجود';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _handleResetPassword() async {
    if (_selectedUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء اختيار المستخدم أولاً'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    try {
      await _authService.resetPassword(_selectedUser!.email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ في إرسال رابط إعادة تعيين كلمة المرور'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  // Method to check database connection and tables
  Future<void> _checkDatabaseConnection() async {
    setState(() => _isLoading = true);

    try {
      // Check connection to Supabase
      final supabaseClient = supabase_flutter.Supabase.instance.client;

      // Try to query the users table
      bool usersTableAvailable = false;
      String usersTableError = '';
      try {
        // استخدام استعلام بسيط بدون دوال تجميع
        await supabaseClient
            .from(SupabaseConfig.usersTable)
            .select('id')
            .limit(1);
        usersTableAvailable = true;
      } catch (e) {
        usersTableError = e.toString();
      }

      // محاولة الاستعلام عن المستخدم الحالي
      bool isAuthenticated = false;
      try {
        final session = supabaseClient.auth.currentSession;
        isAuthenticated = session != null;
      } catch (e) {
        developer.log('Error checking authentication: $e');
      }

      if (mounted) {
        // Show the results
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('حالة الاتصال بقاعدة البيانات'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('الاتصال بـ Supabase: متصل'),
                const SizedBox(height: 8),
                Text(
                    'حالة المصادقة: ${isAuthenticated ? 'مسجل الدخول' : 'غير مسجل الدخول'}'),
                const SizedBox(height: 8),
                Text(
                    'جدول ${SupabaseConfig.usersTable}: ${usersTableAvailable ? 'متاح' : 'غير متاح'}'),
                if (!usersTableAvailable && usersTableError.isNotEmpty)
                  Text('خطأ: $usersTableError',
                      style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 8),
                const Text('جدول auth.users: يتطلب صلاحيات المدير'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إغلاق'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _loadUsers();
                },
                child: const Text('تحديث قائمة المستخدمين'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في الاتصال بقاعدة البيانات: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/Logo.png',
                  width: 120.w,
                  height: 120.w,
                  color: AppTheme.primaryGreen,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.health_and_safety,
                      size: 100.w,
                      color: AppTheme.primaryGreen,
                    );
                  },
                ),
                SizedBox(height: 24.h),
                Text(
                  ' صحتي بلس',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'تسجيل الدخول',
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: AppTheme.textColor,
                  ),
                ),
                SizedBox(height: 48.h),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: FormBuilder(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'تسجيل دخول ',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryGreen,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 24.h),
                          _isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : FormBuilderDropdown<User>(
                                  name: 'user',
                                  decoration: InputDecoration(
                                    labelText: 'اختر المستخدم',
                                    prefixIcon: const Icon(Icons.person),
                                    // Show a hint if no users are available
                                    hintText: _users.isEmpty
                                        ? 'لا يوجد مستخدمين متاحين'
                                        : null,
                                    // Show a suffix icon to refresh the list
                                    suffixIcon: IconButton(
                                      icon: const Icon(Icons.refresh),
                                      onPressed: _loadUsers,
                                      tooltip: 'تحديث قائمة المستخدمين',
                                    ),
                                  ),
                                  items: _users.map((user) {
                                    return DropdownMenuItem(
                                      value: user,
                                      child: Text(user.email),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedUser = value;
                                    });
                                  },
                                  validator: FormBuilderValidators.required(
                                    errorText: 'الرجاء اختيار المستخدم',
                                  ),
                                ),
                          SizedBox(height: 16.h),
                          FormBuilderTextField(
                            name: 'password',
                            decoration: InputDecoration(
                              labelText: 'كلمة المرور',
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            obscureText: _obscurePassword,
                            validator: FormBuilderValidators.required(
                              errorText: 'الرجاء إدخال كلمة المرور',
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: _handleResetPassword,
                              child: const Text('نسيت كلمة المرور؟'),
                            ),
                          ),
                          SizedBox(height: 24.h),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            child: _isLoading
                                ? const CircularProgressIndicator()
                                : const Text('دخول'),
                          ),
                          SizedBox(height: 16.h),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/register');
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              backgroundColor: AppTheme.primaryGreen,
                            ),
                            child: const Text('إنشاء حساب جديد'),
                          ),
                          // Debug button - only visible in development mode
                          Visibility(
                            visible: true, // Set to false in production
                            child: Padding(
                              padding: EdgeInsets.only(top: 16.h),
                              child: Column(
                                children: [
                                  OutlinedButton(
                                    onPressed: _checkDatabaseConnection,
                                    child: const Text(
                                        'فحص الاتصال بقاعدة البيانات'),
                                  ),
                                  SizedBox(height: 8.h),
                                  OutlinedButton.icon(
                                    onPressed: _createDemoUser,
                                    icon: const Icon(Icons.person_add),
                                    label: const Text('إنشاء مستخدم تجريبي'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.green,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  OutlinedButton.icon(
                                    onPressed:
                                        _isLoading ? null : _createTables,
                                    icon: const Icon(Icons.table_chart),
                                    label: const Text('إنشاء الجداول'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text('تطبيق صحتي بلس'),
      ),
    );
  }
}
