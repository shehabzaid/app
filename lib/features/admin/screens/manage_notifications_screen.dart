import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:developer' as developer;
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../notifications/models/notification_model.dart';
import '../../notifications/services/notification_service.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/models/user_profile.dart';

class ManageNotificationsScreen extends StatefulWidget {
  const ManageNotificationsScreen({super.key});

  @override
  State<ManageNotificationsScreen> createState() => _ManageNotificationsScreenState();
}

class _ManageNotificationsScreenState extends State<ManageNotificationsScreen> {
  final _notificationService = NotificationService();
  final _authService = AuthService();
  bool _isLoading = true;
  String _error = '';
  List<NotificationModel> _notifications = [];
  List<NotificationModel> _filteredNotifications = [];
  List<UserProfile> _users = [];
  
  // فلترة
  final _searchController = TextEditingController();
  String? _selectedType;
  UserProfile? _selectedUser;
  bool? _selectedReadStatus;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    
    try {
      // تحميل قائمة المستخدمين
      final users = await _authService.getAllUsers();
      
      // تحميل جميع الإشعارات
      final notifications = await _notificationService.getAllNotifications();
      
      setState(() {
        _users = users;
        _notifications = notifications;
        _filteredNotifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      developer.log('Error loading notifications: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
  
  void _filterNotifications() {
    final searchQuery = _searchController.text.toLowerCase();
    
    setState(() {
      _filteredNotifications = _notifications.where((notification) {
        // تطبيق فلتر البحث
        final matchesSearch = 
            notification.title.toLowerCase().contains(searchQuery) ||
            notification.body.toLowerCase().contains(searchQuery);
        
        // تطبيق فلتر النوع
        final matchesType = _selectedType == null || 
            _selectedType == 'الكل' || 
            notification.type == _selectedType;
        
        // تطبيق فلتر المستخدم
        final matchesUser = _selectedUser == null || 
            notification.userId == _selectedUser!.id;
        
        // تطبيق فلتر حالة القراءة
        final matchesReadStatus = _selectedReadStatus == null || 
            notification.isRead == _selectedReadStatus;
        
        return matchesSearch && matchesType && matchesUser && matchesReadStatus;
      }).toList();
    });
  }
  
  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _selectedType = null;
      _selectedUser = null;
      _selectedReadStatus = null;
      _filteredNotifications = _notifications;
    });
  }
  
  Future<void> _deleteNotification(NotificationModel notification) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف الإشعار "${notification.title}"؟'),
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
      setState(() => _isLoading = true);
      
      try {
        await _notificationService.deleteNotification(notification.id);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حذف الإشعار بنجاح')),
        );
        
        _loadData();
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في حذف الإشعار: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<void> _deleteAllNotifications() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد حذف جميع الإشعارات'),
        content: const Text('هل أنت متأكد من حذف جميع الإشعارات؟ لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف الكل', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      setState(() => _isLoading = true);
      
      try {
        await _notificationService.deleteAllNotifications();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حذف جميع الإشعارات بنجاح')),
        );
        
        _loadData();
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في حذف الإشعارات: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  void _showSendNotificationDialog() {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    String? type;
    UserProfile? selectedUser;
    bool sendToAll = false;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('إرسال إشعار جديد'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'عنوان الإشعار *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال عنوان الإشعار';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: bodyController,
                    decoration: const InputDecoration(
                      labelText: 'محتوى الإشعار *',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال محتوى الإشعار';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'نوع الإشعار',
                      border: OutlineInputBorder(),
                    ),
                    value: type,
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('بدون نوع'),
                      ),
                      const DropdownMenuItem(
                        value: 'system',
                        child: Text('إشعار نظام'),
                      ),
                      const DropdownMenuItem(
                        value: 'appointment',
                        child: Text('موعد'),
                      ),
                      const DropdownMenuItem(
                        value: 'medical_record',
                        child: Text('سجل طبي'),
                      ),
                      const DropdownMenuItem(
                        value: 'promotion',
                        child: Text('عرض ترويجي'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => type = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('إرسال لجميع المستخدمين'),
                    value: sendToAll,
                    onChanged: (value) {
                      setState(() {
                        sendToAll = value;
                        if (value) {
                          selectedUser = null;
                        }
                      });
                    },
                  ),
                  if (!sendToAll) ...[
                    const SizedBox(height: 16),
                    DropdownButtonFormField<UserProfile>(
                      decoration: const InputDecoration(
                        labelText: 'المستخدم المستهدف *',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedUser,
                      items: _users
                          .map((user) => DropdownMenuItem(
                                value: user,
                                child: Text(user.fullName ?? user.email),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() => selectedUser = value);
                      },
                      validator: (value) {
                        if (!sendToAll && value == null) {
                          return 'يرجى اختيار المستخدم المستهدف';
                        }
                        return null;
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  if (!sendToAll && selectedUser == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('يرجى اختيار المستخدم المستهدف'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  
                  Navigator.pop(context);
                  
                  setState(() => _isLoading = true);
                  try {
                    if (sendToAll) {
                      await _notificationService.sendNotificationToAllUsers(
                        title: titleController.text,
                        body: bodyController.text,
                        type: type,
                      );
                    } else {
                      await _notificationService.addNotification(
                        selectedUser!.id,
                        titleController.text,
                        bodyController.text,
                        type: type,
                      );
                    }
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم إرسال الإشعار بنجاح')),
                    );
                    
                    _loadData();
                  } catch (e) {
                    setState(() => _isLoading = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('فشل في إرسال الإشعار: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('إرسال'),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الإشعارات'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'حذف جميع الإشعارات',
            onPressed: _notifications.isNotEmpty ? _deleteAllNotifications : null,
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : _error.isNotEmpty
              ? ErrorView(
                  error: _error,
                  onRetry: _loadData,
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
                                hintText: 'ابحث في الإشعارات',
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 12.h,
                                ),
                              ),
                              onChanged: (_) => _filterNotifications(),
                            ),
                            SizedBox(height: 16.h),
                            
                            // فلاتر إضافية
                            Row(
                              children: [
                                // فلتر النوع
                                Expanded(
                                  child: DropdownButtonFormField<String?>(
                                    decoration: InputDecoration(
                                      labelText: 'نوع الإشعار',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 12.h,
                                      ),
                                    ),
                                    value: _selectedType,
                                    items: [
                                      const DropdownMenuItem(
                                        value: null,
                                        child: Text('الكل'),
                                      ),
                                      const DropdownMenuItem(
                                        value: 'system',
                                        child: Text('إشعار نظام'),
                                      ),
                                      const DropdownMenuItem(
                                        value: 'appointment',
                                        child: Text('موعد'),
                                      ),
                                      const DropdownMenuItem(
                                        value: 'medical_record',
                                        child: Text('سجل طبي'),
                                      ),
                                      const DropdownMenuItem(
                                        value: 'promotion',
                                        child: Text('عرض ترويجي'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() => _selectedType = value);
                                      _filterNotifications();
                                    },
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                
                                // فلتر حالة القراءة
                                Expanded(
                                  child: DropdownButtonFormField<bool?>(
                                    decoration: InputDecoration(
                                      labelText: 'حالة القراءة',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 12.h,
                                      ),
                                    ),
                                    value: _selectedReadStatus,
                                    items: [
                                      const DropdownMenuItem(
                                        value: null,
                                        child: Text('الكل'),
                                      ),
                                      const DropdownMenuItem(
                                        value: true,
                                        child: Text('مقروء'),
                                      ),
                                      const DropdownMenuItem(
                                        value: false,
                                        child: Text('غير مقروء'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() => _selectedReadStatus = value);
                                      _filterNotifications();
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            
                            // فلتر المستخدم
                            DropdownButtonFormField<UserProfile?>(
                              decoration: InputDecoration(
                                labelText: 'المستخدم',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 12.h,
                                ),
                              ),
                              value: _selectedUser,
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('جميع المستخدمين'),
                                ),
                                ..._users.map((user) => DropdownMenuItem(
                                      value: user,
                                      child: Text(user.fullName ?? user.email),
                                    )),
                              ],
                              onChanged: (value) {
                                setState(() => _selectedUser = value);
                                _filterNotifications();
                              },
                            ),
                            SizedBox(height: 16.h),
                            
                            // أزرار إعادة الضبط والإضافة
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton.icon(
                                  onPressed: _resetFilters,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('إعادة ضبط الفلاتر'),
                                ),
                                ElevatedButton.icon(
                                  onPressed: _showSendNotificationDialog,
                                  icon: const Icon(Icons.add),
                                  label: const Text('إرسال إشعار'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryGreen,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 8.h,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
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
                            'النتائج: ${_filteredNotifications.length}',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // قائمة الإشعارات
                    Expanded(
                      child: _filteredNotifications.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.notifications_off,
                                    size: 60.w,
                                    color: Colors.grey[400],
                                  ),
                                  SizedBox(height: 16.h),
                                  Text(
                                    'لا توجد إشعارات مطابقة للبحث',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(height: 16.h),
                                  ElevatedButton.icon(
                                    onPressed: _showSendNotificationDialog,
                                    icon: const Icon(Icons.add),
                                    label: const Text('إرسال إشعار جديد'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryGreen,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.all(8.w),
                              itemCount: _filteredNotifications.length,
                              itemBuilder: (context, index) {
                                final notification = _filteredNotifications[index];
                                return _buildNotificationCard(notification);
                              },
                            ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showSendNotificationDialog,
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildNotificationCard(NotificationModel notification) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: notification.isRead ? Colors.grey.shade300 : Colors.blue.shade200,
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
                // أيقونة الإشعار
                Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    color: _getNotificationColor(notification.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getNotificationIcon(notification.type),
                    size: 30.w,
                    color: _getNotificationColor(notification.type),
                  ),
                ),
                SizedBox(width: 16.w),
                
                // معلومات الإشعار
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 12.w,
                              height: 12.w,
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        notification.body,
                        style: TextStyle(
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          if (notification.type != null) ...[
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: _getNotificationColor(notification.type).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _getNotificationTypeName(notification.type),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: _getNotificationColor(notification.type),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                          ],
                          Icon(Icons.access_time, size: 14.w, color: Colors.grey[600]),
                          SizedBox(width: 4.w),
                          Text(
                            _formatDate(notification.createdAt),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          const Spacer(),
                          FutureBuilder<UserProfile?>(
                            future: _authService.getUserProfileById(notification.userId),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Text('جاري التحميل...');
                              }
                              if (snapshot.hasError || !snapshot.hasData) {
                                return const Text('مستخدم غير معروف');
                              }
                              return Text(
                                'المستلم: ${snapshot.data!.fullName ?? snapshot.data!.email}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey[600],
                                ),
                              );
                            },
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
                  icon: Icons.delete,
                  label: 'حذف',
                  color: Colors.red,
                  onPressed: () => _deleteNotification(notification),
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
  
  IconData _getNotificationIcon(String? type) {
    switch (type) {
      case 'appointment':
        return Icons.calendar_today;
      case 'medical_record':
        return Icons.medical_information;
      case 'system':
        return Icons.info;
      case 'promotion':
        return Icons.campaign;
      default:
        return Icons.notifications;
    }
  }
  
  Color _getNotificationColor(String? type) {
    switch (type) {
      case 'appointment':
        return Colors.blue;
      case 'medical_record':
        return Colors.green;
      case 'system':
        return Colors.purple;
      case 'promotion':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
  
  String _getNotificationTypeName(String? type) {
    switch (type) {
      case 'appointment':
        return 'موعد';
      case 'medical_record':
        return 'سجل طبي';
      case 'system':
        return 'نظام';
      case 'promotion':
        return 'عرض ترويجي';
      default:
        return 'إشعار';
    }
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'منذ ${difference.inMinutes} دقيقة';
      }
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      return '${date.year}/${date.month}/${date.day}';
    }
  }
}
