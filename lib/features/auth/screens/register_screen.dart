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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // خلفية مقسمة
            Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.25,
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
                    SizedBox(height: 20.h),

                    // العنوان
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'إنشاء حساب جديد',
                            style: TextStyle(
                              fontSize: 26.sp,
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
                              'منصة صحتي بلس',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 30.h),

                    // بطاقة التسجيل
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
                                    Icons.person_add_rounded,
                                    color: AppTheme.primaryGreen,
                                    size: 24.r,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'معلومات المستخدم',
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

                              // المعلومات الشخصية
                              Text(
                                'المعلومات الشخصية',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 16.h),

                              // الاسم الكامل
                              FormBuilderTextField(
                                name: 'fullName',
                                decoration: InputDecoration(
                                  labelText: 'الاسم الكامل',
                                  hintText: 'أدخل الاسم الكامل',
                                  prefixIcon: const Icon(Icons.person,
                                      color: AppTheme.primaryGreen),
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
                                    errorText: 'يرجى إدخال الاسم الكامل'),
                              ),
                              SizedBox(height: 16.h),

                              // البريد الإلكتروني
                              FormBuilderTextField(
                                name: 'email',
                                decoration: InputDecoration(
                                  labelText: 'البريد الإلكتروني',
                                  hintText: 'أدخل البريد الإلكتروني',
                                  prefixIcon: const Icon(Icons.email,
                                      color: AppTheme.primaryGreen),
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
                                validator: FormBuilderValidators.compose([
                                  FormBuilderValidators.required(
                                      errorText:
                                          'يرجى إدخال البريد الإلكتروني'),
                                  FormBuilderValidators.email(
                                      errorText:
                                          'يرجى إدخال بريد إلكتروني صحيح'),
                                ]),
                              ),
                              SizedBox(height: 16.h),

                              // رقم الهاتف
                              FormBuilderTextField(
                                name: 'phone',
                                decoration: InputDecoration(
                                  labelText: 'رقم الهاتف',
                                  hintText: 'أدخل رقم الهاتف',
                                  prefixIcon: const Icon(Icons.phone,
                                      color: AppTheme.primaryGreen),
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
                                    errorText: 'يرجى إدخال رقم الهاتف'),
                              ),
                              SizedBox(height: 16.h),

                              // صف الجنس وتاريخ الميلاد
                              Row(
                                children: [
                                  // الجنس
                                  Expanded(
                                    child: FormBuilderDropdown<String>(
                                      name: 'gender',
                                      decoration: InputDecoration(
                                        labelText: 'الجنس',
                                        hintText: 'اختر الجنس',
                                        prefixIcon: const Icon(Icons.people,
                                            color: AppTheme.primaryGreen),
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
                                      items: const [
                                        DropdownMenuItem(
                                            value: 'ذكر', child: Text('ذكر')),
                                        DropdownMenuItem(
                                            value: 'أنثى', child: Text('أنثى')),
                                      ],
                                      dropdownColor: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 16.w),

                                  // تاريخ الميلاد
                                  Expanded(
                                    child: FormBuilderDateTimePicker(
                                      name: 'birthDate',
                                      decoration: InputDecoration(
                                        labelText: 'تاريخ الميلاد',
                                        hintText: 'اختر التاريخ',
                                        prefixIcon: const Icon(
                                            Icons.calendar_today,
                                            color: AppTheme.primaryGreen),
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
                                      inputType: InputType.date,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16.h),

                              // رقم الهوية الوطنية
                              FormBuilderTextField(
                                name: 'nationalId',
                                decoration: InputDecoration(
                                  labelText: 'رقم الهوية الوطنية',
                                  hintText: 'أدخل رقم الهوية الوطنية',
                                  prefixIcon: const Icon(Icons.badge,
                                      color: AppTheme.primaryGreen),
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
                              ),

                              SizedBox(height: 24.h),

                              // معلومات الحساب
                              Text(
                                'معلومات الحساب',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 16.h),

                              // كلمة المرور
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
                                validator: FormBuilderValidators.compose([
                                  FormBuilderValidators.required(
                                      errorText: 'يرجى إدخال كلمة المرور'),
                                  FormBuilderValidators.minLength(6,
                                      errorText:
                                          'يجب أن تكون كلمة المرور 6 أحرف على الأقل'),
                                ]),
                              ),
                              SizedBox(height: 16.h),

                              // تأكيد كلمة المرور
                              FormBuilderTextField(
                                name: 'confirmPassword',
                                obscureText: _obscureConfirmPassword,
                                decoration: InputDecoration(
                                  labelText: 'تأكيد كلمة المرور',
                                  hintText: 'أعد إدخال كلمة المرور',
                                  prefixIcon: const Icon(Icons.lock_outline,
                                      color: AppTheme.primaryGreen),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: AppTheme.primaryGreen,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureConfirmPassword =
                                            !_obscureConfirmPassword;
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
                                    errorText: 'يرجى تأكيد كلمة المرور'),
                              ),

                              SizedBox(height: 32.h),

                              // زر إنشاء الحساب
                              ElevatedButton(
                                onPressed: _isLoading ? null : _handleRegister,
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
                                          const Icon(Icons.person_add),
                                          SizedBox(width: 8.w),
                                          const Text(
                                            'إنشاء حساب جديد',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),

                              SizedBox(height: 16.h),

                              // زر العودة لتسجيل الدخول
                              TextButton(
                                onPressed: () => Navigator.pushReplacementNamed(
                                    context, '/login'),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.arrow_back_ios, size: 16),
                                    SizedBox(width: 8.w),
                                    const Text(
                                        'لديك حساب بالفعل؟ تسجيل الدخول'),
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
