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

  // تم إزالة الدوال غير المستخدمة (_createDemoUser, _createTables, _checkDatabaseConnection)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // خلفية مقسمة
            Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.35,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppTheme.primaryGreen,
                        AppTheme.primaryGreen.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30.r),
                      bottomRight: Radius.circular(30.r),
                    ),
                  ),
                ),
                Expanded(child: Container()),
              ],
            ),

            // محتوى الصفحة
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    SizedBox(height: 40.h),
                    // الشعار والعنوان
                    Center(
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(16.r),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/Logo.png',
                              width: 80.w,
                              height: 80.w,
                              color: AppTheme.primaryGreen,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.health_and_safety,
                                    size: 80.w, color: AppTheme.primaryGreen);
                              },
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'منصة صحتي بلس',
                            style: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              'تسجيل الدخول',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 40.h),

                    // بطاقة تسجيل الدخول
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(24.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.r),
                          color: Colors.white,
                        ),
                        child: FormBuilder(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // عنوان البطاقة
                              Row(
                                children: [
                                  Icon(
                                    Icons.login_rounded,
                                    color: AppTheme.primaryGreen,
                                    size: 24.r,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'معلومات الدخول',
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryGreen,
                                    ),
                                  ),
                                ],
                              ),

                              Divider(
                                  height: 32.h,
                                  color: Colors.grey.withOpacity(0.3)),

                              // حقل اختيار المستخدم
                              _isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : FormBuilderDropdown<UserProfile>(
                                      name: 'user',
                                      decoration: InputDecoration(
                                        labelText: 'اختر المستخدم',
                                        hintText: 'اختر البريد الإلكتروني',
                                        prefixIcon: const Icon(Icons.person,
                                            color: AppTheme.primaryGreen),
                                        suffixIcon: IconButton(
                                          icon: const Icon(Icons.refresh,
                                              color: AppTheme.primaryGreen),
                                          onPressed: _loadUsers,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12.r),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12.r),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12.r),
                                          borderSide: const BorderSide(
                                              color: AppTheme.primaryGreen,
                                              width: 2),
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey.shade50,
                                      ),
                                      items: _users.map((user) {
                                        return DropdownMenuItem(
                                          value: user,
                                          child: Text(user.email),
                                        );
                                      }).toList(),
                                      onChanged: (value) =>
                                          _selectedUser = value,
                                      validator: FormBuilderValidators.required(
                                          errorText: 'يرجى اختيار مستخدم'),
                                      dropdownColor: Colors.white,
                                    ),

                              SizedBox(height: 20.h),

                              // حقل كلمة المرور
                              FormBuilderTextField(
                                name: 'password',
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: 'كلمة المرور',
                                  hintText: 'أدخل كلمة المرور',
                                  prefixIcon: const Icon(Icons.lock,
                                      color: AppTheme.primaryGreen),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: AppTheme.primaryGreen,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade300),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                    borderSide: const BorderSide(
                                        color: AppTheme.primaryGreen, width: 2),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                ),
                                validator: FormBuilderValidators.required(
                                    errorText: 'يرجى إدخال كلمة المرور'),
                              ),

                              SizedBox(height: 12.h),

                              // زر نسيت كلمة المرور
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton.icon(
                                  onPressed: _handleResetPassword,
                                  icon:
                                      const Icon(Icons.help_outline, size: 18),
                                  label: const Text('نسيت كلمة المرور؟'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppTheme.primaryGreen,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8.w, vertical: 4.h),
                                  ),
                                ),
                              ),

                              SizedBox(height: 24.h),

                              // زر تسجيل الدخول
                              ElevatedButton(
                                onPressed: _isLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryGreen,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 16.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  elevation: 2,
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white)
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.login),
                                          SizedBox(width: 8.w),
                                          const Text(
                                            'تسجيل الدخول',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),

                              SizedBox(height: 16.h),

                              // زر إنشاء حساب جديد
                              OutlinedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/register');
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.primaryGreen,
                                  side: const BorderSide(
                                      color: AppTheme.primaryGreen),
                                  padding: EdgeInsets.symmetric(vertical: 16.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.person_add),
                                    SizedBox(width: 8.w),
                                    const Text(
                                      'إنشاء حساب جديد',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
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

                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),

            // زر الرجوع
            Positioned(
              top: 16.h,
              left: 16.w,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
