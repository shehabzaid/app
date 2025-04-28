import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../../../core/theme/app_theme.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final AuthService _authService = AuthService();
  
  bool _isLoading = true;
  bool _isSaving = false;
  UserProfile? _userProfile;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userProfile = await _authService.getCurrentUserProfile();
      setState(() {
        _userProfile = userProfile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'فشل في تحميل بيانات المستخدم: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.red,
                fontSize: 16.sp,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: _loadUserProfile,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (_userProfile == null) {
      return const Center(
        child: Text('لا توجد بيانات'),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildProfileHeader(),
          SizedBox(height: 24.h),
          _buildProfileForm(),
          SizedBox(height: 24.h),
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 50.r,
          backgroundColor: Colors.grey[200],
          backgroundImage: _userProfile!.profilePicture != null
              ? NetworkImage(_userProfile!.profilePicture!)
              : null,
          child: _userProfile!.profilePicture == null
              ? Icon(
                  Icons.person,
                  size: 50.r,
                  color: Colors.grey[400],
                )
              : null,
        ),
        SizedBox(height: 16.h),
        Text(
          _userProfile!.fullName ?? _userProfile!.email,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          _userProfile!.email,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 8.h),
        OutlinedButton.icon(
          onPressed: _pickProfilePicture,
          icon: const Icon(Icons.camera_alt),
          label: const Text('تغيير الصورة'),
        ),
      ],
    );
  }

  Widget _buildProfileForm() {
    return FormBuilder(
      key: _formKey,
      initialValue: {
        'full_name': _userProfile!.fullName ?? '',
        'phone': _userProfile!.phone ?? '',
        'gender': _userProfile!.gender ?? '',
        'national_id': _userProfile!.nationalId ?? '',
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المعلومات الشخصية',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGreen,
            ),
          ),
          SizedBox(height: 16.h),
          FormBuilderTextField(
            name: 'full_name',
            decoration: InputDecoration(
              labelText: 'الاسم الكامل',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),
            ),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(errorText: 'هذا الحقل مطلوب'),
            ]),
          ),
          SizedBox(height: 16.h),
          FormBuilderTextField(
            name: 'phone',
            decoration: InputDecoration(
              labelText: 'رقم الهاتف',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),
            ),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(errorText: 'هذا الحقل مطلوب'),
            ]),
          ),
          SizedBox(height: 16.h),
          FormBuilderDropdown(
            name: 'gender',
            decoration: InputDecoration(
              labelText: 'الجنس',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),
            ),
            items: const [
              DropdownMenuItem(
                value: 'male',
                child: Text('ذكر'),
              ),
              DropdownMenuItem(
                value: 'female',
                child: Text('أنثى'),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          FormBuilderTextField(
            name: 'national_id',
            decoration: InputDecoration(
              labelText: 'رقم الهوية',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),
            ),
          ),
          SizedBox(height: 24.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: _isSaving
                  ? SizedBox(
                      height: 20.h,
                      width: 20.w,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'حفظ التغييرات',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _logout,
        icon: const Icon(Icons.logout, color: Colors.red),
        label: Text(
          'تسجيل الخروج',
          style: TextStyle(
            color: Colors.red,
            fontSize: 16.sp,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          side: const BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      ),
    );
  }

  void _pickProfilePicture() {
    // TODO: Implement profile picture selection
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('سيتم تنفيذ هذه الميزة قريباً'),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() {
        _isSaving = true;
      });

      try {
        final formData = _formKey.currentState!.value;
        
        final updatedProfile = _userProfile!.copyWith(
          fullName: formData['full_name'],
          phone: formData['phone'],
          gender: formData['gender'],
          nationalId: formData['national_id'],
        );
        
        await _authService.updateUserProfile(updatedProfile);
        
        setState(() {
          _userProfile = updatedProfile;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حفظ التغييرات بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('حدث خطأ: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد تسجيل الخروج'),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _authService.logout();
                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('فشل في تسجيل الخروج: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'تسجيل الخروج',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
