import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/navigation/app_navigator.dart';
import '../services/auth_service.dart';
import '../models/user_profile.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _authService = AuthService();

  List<UserProfile> _users = [];
  UserProfile? _selectedUser;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await _authService.getAllUsers();
      if (mounted) {
        setState(() {
          _users = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء تحميل المستخدمين: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() => _isLoading = true);
      try {
        final password = _formKey.currentState!.value['password'] as String;
        if (_selectedUser == null) {
          throw Exception('يرجى اختيار مستخدم');
        }

        final result = await _authService.login(
          email: _selectedUser!.email,
          password: password,
        );

        if (result != null && mounted) {
          String role = result['role'];
          AppNavigator.navigateToHome(context, role.toLowerCase());
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ أثناء تسجيل الدخول: ${e.toString()}'),
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
          content: Text('يرجى اختيار مستخدم أولاً'),
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
            content: Text('حدث خطأ أثناء إرسال رابط إعادة التعيين'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _createDemoUser() async {
    // تقدر تضيف هنا if needed عملية إنشاء مستخدم تجريبي من AuthService
  }

  Future<void> _createTables() async {
    // تقدر تضيف هنا عملية إنشاء الجداول إذا ما كانت موجودة
  }

  Future<void> _checkDatabaseConnection() async {
    // تقدر تضيف هنا عملية فحص الاتصال بقاعدة البيانات
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('تسجيل الدخول - منصة صحتي بلس'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Column(
              children: [
                Image.asset(
                  'assets/images/Logo.png',
                  width: 120.w,
                  height: 120.w,
                  color: AppTheme.primaryGreen,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.health_and_safety,
                        size: 100.w, color: AppTheme.primaryGreen);
                  },
                ),
                SizedBox(height: 24.h),
                Text(
                  'منصة صحتي بلس',
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
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: FormBuilder(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'معلومات الدخول',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                          SizedBox(height: 24.h),
                          _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : FormBuilderDropdown<UserProfile>(
                                  name: 'user',
                                  decoration: InputDecoration(
                                    labelText: 'اختر المستخدم',
                                    prefixIcon: const Icon(Icons.person),
                                    suffixIcon: IconButton(
                                      icon: const Icon(Icons.refresh),
                                      onPressed: _loadUsers,
                                    ),
                                  ),
                                  items: _users.map((user) {
                                    return DropdownMenuItem(
                                      value: user,
                                      child: Text(user.email),
                                    );
                                  }).toList(),
                                  onChanged: (value) => _selectedUser = value,
                                  validator: FormBuilderValidators.required(
                                      errorText: 'يرجى اختيار مستخدم'),
                                ),
                          SizedBox(height: 16.h),
                          FormBuilderTextField(
                            name: 'password',
                            obscureText: _obscurePassword,
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
                            validator: FormBuilderValidators.required(
                                errorText: 'يرجى إدخال كلمة المرور'),
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
                              backgroundColor: AppTheme.primaryGreen,
                            ),
                            child: const Text('إنشاء حساب جديد'),
                          ),
                          SizedBox(height: 16.h),
                          OutlinedButton(
                            onPressed: _checkDatabaseConnection,
                            child: const Text('فحص الاتصال بقاعدة البيانات'),
                          ),
                          SizedBox(height: 8.h),
                          OutlinedButton(
                            onPressed: _createDemoUser,
                            child: const Text('إنشاء مستخدم تجريبي'),
                          ),
                          SizedBox(height: 8.h),
                          OutlinedButton(
                            onPressed: _createTables,
                            child: const Text('إنشاء الجداول'),
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
    );
  }
}
