import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _authService = AuthService();
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'ar';
  bool _isLoading = false;

  Future<void> _logout() async {
    setState(() => _isLoading = true);
    
    try {
      await _authService.logout();
      
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: ${e.toString()}')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اختر اللغة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('العربية'),
              value: 'ar',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                Navigator.pop(context);
                setState(() => _selectedLanguage = value!);
                // TODO: Implement language change
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                Navigator.pop(context);
                setState(() => _selectedLanguage = value!);
                // TODO: Implement language change
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(16.w),
              children: [
                // قسم الحساب
                _buildSectionTitle('الحساب'),
                _buildSettingItem(
                  icon: Icons.person,
                  title: 'الملف الشخصي',
                  subtitle: 'عرض وتعديل معلومات الملف الشخصي',
                  onTap: () {
                    // TODO: Navigate to profile screen
                  },
                ),
                _buildSettingItem(
                  icon: Icons.security,
                  title: 'الأمان',
                  subtitle: 'تغيير كلمة المرور وإعدادات الأمان',
                  onTap: () {
                    // TODO: Navigate to security settings
                  },
                ),
                
                const Divider(),
                
                // قسم التطبيق
                _buildSectionTitle('إعدادات التطبيق'),
                _buildSwitchSettingItem(
                  icon: Icons.dark_mode,
                  title: 'الوضع الداكن',
                  value: _isDarkMode,
                  onChanged: (value) {
                    setState(() => _isDarkMode = value);
                    // TODO: Implement dark mode
                  },
                ),
                _buildSwitchSettingItem(
                  icon: Icons.notifications,
                  title: 'الإشعارات',
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() => _notificationsEnabled = value);
                    // TODO: Implement notifications toggle
                  },
                ),
                _buildSettingItem(
                  icon: Icons.language,
                  title: 'اللغة',
                  subtitle: _selectedLanguage == 'ar' ? 'العربية' : 'English',
                  onTap: _showLanguageDialog,
                ),
                
                const Divider(),
                
                // قسم المساعدة
                _buildSectionTitle('المساعدة والدعم'),
                _buildSettingItem(
                  icon: Icons.help,
                  title: 'مركز المساعدة',
                  subtitle: 'الأسئلة الشائعة والمساعدة',
                  onTap: () {
                    // TODO: Navigate to help center
                  },
                ),
                _buildSettingItem(
                  icon: Icons.contact_support,
                  title: 'تواصل معنا',
                  subtitle: 'اتصل بفريق الدعم',
                  onTap: () {
                    // TODO: Navigate to contact us
                  },
                ),
                _buildSettingItem(
                  icon: Icons.privacy_tip,
                  title: 'سياسة الخصوصية',
                  onTap: () {
                    // TODO: Navigate to privacy policy
                  },
                ),
                _buildSettingItem(
                  icon: Icons.description,
                  title: 'شروط الاستخدام',
                  onTap: () {
                    // TODO: Navigate to terms of service
                  },
                ),
                
                const Divider(),
                
                // زر تسجيل الخروج
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: ListTile(
                    leading: Icon(
                      Icons.logout,
                      color: Colors.red,
                      size: 24.w,
                    ),
                    title: const Text(
                      'تسجيل الخروج',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: _showLogoutConfirmation,
                  ),
                ),
                
                // معلومات التطبيق
                SizedBox(height: 24.h),
                Center(
                  child: Column(
                    children: [
                      Text(
                        'صحتي بلس',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'الإصدار 1.0.0',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryGreen,
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: ListTile(
        leading: Icon(
          icon,
          color: AppTheme.primaryGreen,
          size: 24.w,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              )
            : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchSettingItem({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: ListTile(
        leading: Icon(
          icon,
          color: AppTheme.primaryGreen,
          size: 24.w,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.primaryGreen,
        ),
      ),
    );
  }
}
