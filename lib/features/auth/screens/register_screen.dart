import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/navigation/app_navigator.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _handleRegister() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() => _isLoading = true);
      try {
        final formData = _formKey.currentState!.value;

        if (formData['password'] != formData['confirmPassword']) {
          throw Exception('كلمات المرور غير متطابقة');
        }

        // التحقق من قوة كلمة المرور
        final password = formData['password'] as String;
        final passwordError = _authService.validatePassword(password);
        if (passwordError != null) {
          throw Exception(passwordError);
        }

        // طباعة بيانات التسجيل للتصحيح
        final email = formData['email'] as String;
        final fullName = formData['fullName'] as String;
        final phoneNumber = formData['phoneNumber'] as String? ?? '';

        debugPrint('Registration data:');
        debugPrint('Email: $email');
        debugPrint('Full Name: $fullName');
        debugPrint('Phone Number: $phoneNumber');

        // إنشاء الحساب وحفظ البيانات
        await _authService.register(
          email: email,
          password: password,
          fullName: fullName,
          phoneNumber: phoneNumber,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'تم إنشاء الحساب بنجاح! يرجى تفعيل حسابك من خلال البريد الإلكتروني'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 5),
            ),
          );
          // العودة إلى شاشة تسجيل الدخول
          Navigator.pushReplacementNamed(context, '/login');
        }
      } catch (e) {
        if (mounted) {
          // تنسيق رسالة الخطأ
          String errorMessage = e.toString();
          if (errorMessage.contains('Exception: ')) {
            errorMessage = errorMessage.replaceAll('Exception: ', '');
          }

          // طباعة الخطأ الكامل للتصحيح
          debugPrint('Registration error: $e');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppTheme.errorColor,
              duration: const Duration(seconds: 5),
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
      appBar: AppBar(
        title: const Text('إنشاء حساب جديد'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            children: [
              // أيقونة وشعار التطبيق
              Icon(
                Icons.health_and_safety,
                size: 100.w,
                color: AppTheme.primaryGreen,
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
              SizedBox(height: 32.h),
              // نموذج التسجيل
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: FormBuilder(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FormBuilderTextField(
                          name: 'fullName',
                          decoration: const InputDecoration(
                            labelText: 'الاسم الكامل',
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: FormBuilderValidators.required(
                            errorText: 'الرجاء إدخال الاسم الكامل',
                          ),
                        ),
                        SizedBox(height: 16.h),
                        FormBuilderTextField(
                          name: 'email',
                          decoration: const InputDecoration(
                            labelText: 'البريد الإلكتروني',
                            prefixIcon: Icon(Icons.email),
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(
                              errorText: 'الرجاء إدخال البريد الإلكتروني',
                            ),
                            FormBuilderValidators.email(
                              errorText: 'الرجاء إدخال بريد إلكتروني صحيح',
                            ),
                          ]),
                        ),
                        SizedBox(height: 16.h),
                        FormBuilderTextField(
                          name: 'phoneNumber',
                          decoration: const InputDecoration(
                            labelText: 'رقم الهاتف',
                            prefixIcon: Icon(Icons.phone),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(
                              errorText: 'الرجاء إدخال رقم الهاتف',
                            ),
                            FormBuilderValidators.minLength(
                              10,
                              errorText:
                                  'رقم الهاتف يجب أن يكون 10 أرقام على الأقل',
                            ),
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
                            helperText:
                                'مثال: Admin@2024\nيجب أن تحتوي كلمة المرور على:\n• 8 أحرف على الأقل\n• حرف كبير\n• حرف صغير\n• رقم\n• رمز خاص مثل @\$!%*?&',
                            helperMaxLines: 6,
                          ),
                          obscureText: _obscurePassword,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(
                              errorText: 'الرجاء إدخال كلمة المرور',
                            ),
                            FormBuilderValidators.minLength(
                              6,
                              errorText:
                                  'كلمة المرور يجب أن تكون 6 أحرف على الأقل',
                            ),
                          ]),
                        ),
                        SizedBox(height: 16.h),
                        FormBuilderTextField(
                          name: 'confirmPassword',
                          decoration: InputDecoration(
                            labelText: 'تأكيد كلمة المرور',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                          obscureText: _obscureConfirmPassword,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(
                              errorText: 'الرجاء تأكيد كلمة المرور',
                            ),
                          ]),
                        ),
                        SizedBox(height: 24.h),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleRegister,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            backgroundColor: AppTheme.primaryGreen,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : Text(
                                  'إنشاء حساب',
                                  style: TextStyle(fontSize: 16.sp),
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
    );
  }
}
