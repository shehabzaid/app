import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:developer' as developer;
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../auth/models/user_profile.dart';
import '../../auth/services/auth_service.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final _authService = AuthService();
  bool _isLoading = true;
  String _error = '';
  List<UserProfile> _users = [];
  List<UserProfile> _filteredUsers = [];
  
  // فلترة
  final _searchController = TextEditingController();
  String? _selectedRole;
  List<String> _roles = ['الكل', 'Patient', 'Doctor', 'Admin'];
  bool? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final users = await _authService.getAllUsers();
      
      setState(() {
        _users = users;
        _filteredUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      developer.log('Error loading users: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterUsers() {
    final searchQuery = _searchController.text.toLowerCase();
    
    setState(() {
      _filteredUsers = _users.where((user) {
        // تطبيق فلتر البحث
        final matchesSearch = 
            user.fullName?.toLowerCase().contains(searchQuery) == true ||
            user.email.toLowerCase().contains(searchQuery) ||
            user.phone?.toLowerCase().contains(searchQuery) == true;
        
        // تطبيق فلتر الدور
        final matchesRole = _selectedRole == null || 
            _selectedRole == 'الكل' || 
            user.role == _selectedRole;
        
        // تطبيق فلتر الحالة
        final matchesStatus = _selectedStatus == null || 
            user.isActive == _selectedStatus;
        
        return matchesSearch && matchesRole && matchesStatus;
      }).toList();
    });
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _selectedRole = null;
      _selectedStatus = null;
      _filteredUsers = _users;
    });
  }

  Future<void> _changeUserRole(UserProfile user, String newRole) async {
    try {
      setState(() => _isLoading = true);
      
      await _authService.updateUserRole(user.id, newRole);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم تغيير دور المستخدم إلى $newRole بنجاح')),
      );
      
      _loadUsers();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في تغيير دور المستخدم: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _toggleUserStatus(UserProfile user) async {
    try {
      setState(() => _isLoading = true);
      
      await _authService.updateUserStatus(user.id, !user.isActive);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            user.isActive 
                ? 'تم تعطيل حساب المستخدم بنجاح' 
                : 'تم تفعيل حساب المستخدم بنجاح'
          ),
        ),
      );
      
      _loadUsers();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في تغيير حالة المستخدم: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteUser(UserProfile user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف حساب المستخدم ${user.fullName ?? user.email}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        setState(() => _isLoading = true);
        
        await _authService.deleteUser(user.id);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حذف حساب المستخدم بنجاح')),
        );
        
        _loadUsers();
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في حذف حساب المستخدم: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showChangeRoleDialog(UserProfile user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تغيير دور المستخدم'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('المستخدم: ${user.fullName ?? user.email}'),
            Text('الدور الحالي: ${user.role}'),
            const SizedBox(height: 16),
            const Text('اختر الدور الجديد:'),
            const SizedBox(height: 8),
            ...['Patient', 'Doctor', 'Admin']
                .where((role) => role != user.role)
                .map((role) => ListTile(
                      title: Text(role),
                      onTap: () {
                        Navigator.pop(context);
                        _changeUserRole(user, role);
                      },
                    ))
                .toList(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المستخدمين'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : _error.isNotEmpty
              ? ErrorView(
                  error: _error,
                  onRetry: _loadUsers,
                )
              : Column(
                  children: [
                    // أدوات البحث والفلترة
                    Card(
                      margin: EdgeInsets.all(8.w),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          children: [
                            // حقل البحث
                            TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'ابحث بالاسم أو البريد الإلكتروني أو رقم الهاتف',
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 12.h,
                                ),
                              ),
                              onChanged: (_) => _filterUsers(),
                            ),
                            SizedBox(height: 16.h),

                            // فلاتر إضافية
                            Row(
                              children: [
                                // فلتر الدور
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      labelText: 'الدور',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 12.h,
                                      ),
                                    ),
                                    value: _selectedRole,
                                    items: _roles
                                        .map((role) => DropdownMenuItem(
                                              value: role,
                                              child: Text(role),
                                            ))
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() => _selectedRole = value);
                                      _filterUsers();
                                    },
                                  ),
                                ),
                                SizedBox(width: 16.w),

                                // فلتر الحالة
                                Expanded(
                                  child: DropdownButtonFormField<bool?>(
                                    decoration: InputDecoration(
                                      labelText: 'الحالة',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 12.h,
                                      ),
                                    ),
                                    value: _selectedStatus,
                                    items: [
                                      const DropdownMenuItem(
                                        value: null,
                                        child: Text('الكل'),
                                      ),
                                      const DropdownMenuItem(
                                        value: true,
                                        child: Text('نشط'),
                                      ),
                                      const DropdownMenuItem(
                                        value: false,
                                        child: Text('غير نشط'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() => _selectedStatus = value);
                                      _filterUsers();
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),

                            // أزرار إعادة الضبط
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: _resetFilters,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('إعادة ضبط الفلاتر'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // عدد النتائج
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      child: Row(
                        children: [
                          Text(
                            'النتائج: ${_filteredUsers.length}',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // قائمة المستخدمين
                    Expanded(
                      child: _filteredUsers.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.people,
                                    size: 60.w,
                                    color: Colors.grey[400],
                                  ),
                                  SizedBox(height: 16.h),
                                  Text(
                                    'لا يوجد مستخدمين مطابقين للبحث',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.all(8.w),
                              itemCount: _filteredUsers.length,
                              itemBuilder: (context, index) {
                                final user = _filteredUsers[index];
                                return _buildUserCard(user);
                              },
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildUserCard(UserProfile user) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: user.isActive ? Colors.green.shade200 : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // صورة المستخدم
                CircleAvatar(
                  radius: 30.r,
                  backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                  child: user.profilePicture != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(30.r),
                          child: Image.network(
                            user.profilePicture!,
                            width: 60.w,
                            height: 60.w,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.person,
                              size: 30.w,
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.person,
                          size: 30.w,
                          color: AppTheme.primaryGreen,
                        ),
                ),
                SizedBox(width: 16.w),

                // معلومات المستخدم
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName ?? 'بدون اسم',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(Icons.email, size: 16.w, color: Colors.grey[600]),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              user.email,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (user.phone != null) ...[
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Icon(Icons.phone, size: 16.w, color: Colors.grey[600]),
                            SizedBox(width: 4.w),
                            Text(
                              user.phone!,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(Icons.badge, size: 16.w, color: Colors.grey[600]),
                          SizedBox(width: 4.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: _getRoleColor(user.role).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              user.role,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: _getRoleColor(user.role),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: user.isActive
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              user.isActive ? 'نشط' : 'غير نشط',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: user.isActive ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // أزرار الإجراءات
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildActionButton(
                  icon: Icons.manage_accounts,
                  label: 'تغيير الدور',
                  color: Colors.blue,
                  onPressed: () => _showChangeRoleDialog(user),
                ),
                SizedBox(width: 8.w),
                _buildActionButton(
                  icon: user.isActive ? Icons.block : Icons.check_circle,
                  label: user.isActive ? 'تعطيل' : 'تفعيل',
                  color: user.isActive ? Colors.orange : Colors.green,
                  onPressed: () => _toggleUserStatus(user),
                ),
                SizedBox(width: 8.w),
                _buildActionButton(
                  icon: Icons.delete,
                  label: 'حذف',
                  color: Colors.red,
                  onPressed: () => _deleteUser(user),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: color, size: 18.w),
      label: Text(
        label,
        style: TextStyle(color: color),
      ),
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: 12.w,
          vertical: 8.h,
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'Admin':
        return Colors.purple;
      case 'Doctor':
        return Colors.blue;
      case 'Patient':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
