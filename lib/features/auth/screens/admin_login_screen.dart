import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/navigation/app_navigator.dart';
import '../services/auth_service.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() => _isLoading = true);
      try {
        final email = _formKey.currentState!.value['username'] as String;
        final password = _formKey.currentState!.value['password'] as String;

        final user = await _authService.login(
          email: email,
          password: password,
        );

        if (user != null && user['isAdmin'] == true) {
          if (mounted) {
            AppNavigator.navigateToHome(context, 'admin');
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('ليس لديك صلاحية الوصول للوحة التحكم'),
                backgroundColor: AppTheme.errorColor,
              ),
            );
            await _authService.logout();
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('حدث خطأ: ${e.toString()}'),
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
                Icon(
                  Icons.admin_panel_settings,
                  size: 100.w,
                  color: AppTheme.primaryGreen,
                ),
                SizedBox(height: 24.h),
                Text(
                  'روابي النهضة التنموية',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'لوحة تحكم المسؤول',
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
                            'تسجيل دخول المسؤول',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryGreen,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 24.h),
                          FormBuilderTextField(
                            name: 'username',
                            decoration: const InputDecoration(
                              labelText: 'البريد الإلكتروني',
                              prefixIcon: Icon(Icons.email),
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(
                                  errorText: 'الرجاء إدخال البريد الإلكتروني'),
                              FormBuilderValidators.email(
                                  errorText: 'الرجاء إدخال بريد إلكتروني صحيح'),
                            ]),
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
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(
                                  errorText: 'الرجاء إدخال كلمة المرور'),
                            ]),
                          ),
                          SizedBox(height: 24.h),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            child: _isLoading
                                ? const CircularProgressIndicator()
                                : const Text('دخول'),
                          ),
                          SizedBox(height: 16.h),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('العودة لتسجيل دخول الموظفين'),
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
