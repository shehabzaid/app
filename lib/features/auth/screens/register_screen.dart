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

        final email = formData['email'] as String;
        final password = formData['password'] as String;
        final confirmPassword = formData['confirmPassword'] as String;
        final fullName = formData['fullName'] as String;
        final phone = formData['phone'] as String;
        final gender = formData['gender'] as String?;
        final birthDate = formData['birthDate'] as DateTime?;
        final nationalId = formData['nationalId'] as String?;

        if (password != confirmPassword) {
          throw Exception('كلمتا المرور غير متطابقتين');
        }

        await _authService.register(
          email: email,
          password: password,
          fullName: fullName,
          phone: phone,
          gender: gender,
          birthDate: birthDate,
          nationalId: nationalId,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إنشاء الحساب بنجاح!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacementNamed(context, '/login');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ أثناء إنشاء الحساب: ${e.toString()}'),
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
      appBar: AppBar(
        title: const Text('إنشاء حساب جديد'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              children: [
                FormBuilderTextField(
                  name: 'fullName',
                  decoration: const InputDecoration(labelText: 'الاسم الكامل'),
                  validator: FormBuilderValidators.required(),
                ),
                SizedBox(height: 16.h),
                FormBuilderTextField(
                  name: 'email',
                  decoration:
                      const InputDecoration(labelText: 'البريد الإلكتروني'),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.email(),
                  ]),
                ),
                SizedBox(height: 16.h),
                FormBuilderTextField(
                  name: 'phone',
                  decoration: const InputDecoration(labelText: 'رقم الهاتف'),
                  validator: FormBuilderValidators.required(),
                ),
                SizedBox(height: 16.h),
                FormBuilderDropdown<String>(
                  name: 'gender',
                  decoration: const InputDecoration(labelText: 'الجنس'),
                  items: const [
                    DropdownMenuItem(value: 'ذكر', child: Text('ذكر')),
                    DropdownMenuItem(value: 'أنثى', child: Text('أنثى')),
                  ],
                ),
                SizedBox(height: 16.h),
                FormBuilderDateTimePicker(
                  name: 'birthDate',
                  decoration: const InputDecoration(labelText: 'تاريخ الميلاد'),
                  inputType: InputType.date,
                ),
                SizedBox(height: 16.h),
                FormBuilderTextField(
                  name: 'nationalId',
                  decoration:
                      const InputDecoration(labelText: 'رقم الهوية الوطنية'),
                ),
                SizedBox(height: 16.h),
                FormBuilderTextField(
                  name: 'password',
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور',
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
                  validator: FormBuilderValidators.minLength(6),
                ),
                SizedBox(height: 16.h),
                FormBuilderTextField(
                  name: 'confirmPassword',
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'تأكيد كلمة المرور',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: FormBuilderValidators.required(),
                ),
                SizedBox(height: 24.h),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('إنشاء حساب'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
