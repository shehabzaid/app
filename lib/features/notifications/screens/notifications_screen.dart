import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/navigation/app_navigator.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_view.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  List<NotificationModel> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        setState(() {
          _hasError = true;
          _errorMessage = 'لم يتم العثور على المستخدم. يرجى تسجيل الدخول.';
          _isLoading = false;
        });
        return;
      }

      final notifications = await _notificationService
          .getUserNotifications(userId, forceRefresh: true);

      if (mounted) {
        setState(() {
          _notifications = notifications;
          _isLoading = false;
        });
      }
    } catch (e) {
      developer.log('Error loading notifications: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'فشل في تحميل الإشعارات: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<String?> _getCurrentUserId() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    return currentUser?.id;
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    try {
      await _notificationService.markNotificationAsRead(notification.id);

      // تحديث القائمة محليًا
      setState(() {
        final index = _notifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          _notifications[index] = notification.copyWith(isRead: true);
        }
      });

      // التنقل حسب نوع الإشعار
      _navigateBasedOnNotificationType(notification);
    } catch (e) {
      developer.log('Error marking notification as read: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في تحديث حالة الإشعار: $e')),
      );
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) return;

      await _notificationService.markAllNotificationsAsRead(userId);

      // تحديث القائمة محليًا
      setState(() {
        _notifications = _notifications
            .map((notification) => notification.copyWith(isRead: true))
            .toList();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تعيين جميع الإشعارات كمقروءة')),
      );
    } catch (e) {
      developer.log('Error marking all notifications as read: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في تحديث حالة الإشعارات: $e')),
      );
    }
  }

  void _navigateBasedOnNotificationType(NotificationModel notification) {
    if (!mounted) return;

    // التنقل حسب نوع الإشعار
    switch (notification.type) {
      case 'appointment':
        if (notification.referenceId != null) {
          AppNavigator.navigateToAppointmentDetails(
              context, notification.referenceId!);
        }
        break;
      case 'medical_record':
        if (notification.referenceId != null) {
          AppNavigator.navigateToMedicalRecordDetails(
              context, notification.referenceId!);
        }
        break;
      // يمكن إضافة المزيد من أنواع الإشعارات هنا
      default:
        // لا شيء للتنقل إليه
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        centerTitle: true,
        actions: [
          if (unreadCount > 0)
            IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: 'تعيين الكل كمقروء',
              onPressed: _markAllAsRead,
            ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : _hasError
              ? ErrorView(
                  error: _errorMessage,
                  onRetry: _loadNotifications,
                )
              : _notifications.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadNotifications,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          return _buildNotificationCard(_notifications[index]);
                        },
                      ),
                    ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80.w,
            color: Colors.grey,
          ),
          SizedBox(height: 16.h),
          const Text(
            'لا توجد إشعارات',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          const Text(
            'ستظهر هنا الإشعارات الجديدة',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    // تحديد لون وأيقونة الإشعار حسب النوع
    IconData iconData;
    Color iconColor;

    switch (notification.type) {
      case 'appointment':
        iconData = Icons.calendar_today;
        iconColor = Colors.blue;
        break;
      case 'medical_record':
        iconData = Icons.medical_information;
        iconColor = Colors.green;
        break;
      case 'doctor_rating':
        iconData = Icons.star;
        iconColor = Colors.amber;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = Colors.grey;
    }

    return Card(
      margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
      elevation: notification.isRead ? 1 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: notification.isRead
              ? Colors.transparent
              : AppTheme.primaryGreen.withOpacity(0.5),
          width: 1,
        ),
      ),
      color:
          notification.isRead ? null : AppTheme.primaryGreen.withOpacity(0.05),
      child: InkWell(
        onTap: () => _markAsRead(notification),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // أيقونة الإشعار
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  iconData,
                  color: iconColor,
                  size: 20.w,
                ),
              ),
              SizedBox(width: 12.w),

              // محتوى الإشعار
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: notification.isRead
                            ? FontWeight.normal
                            : FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      notification.body,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      _formatDate(notification.createdAt),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              // مؤشر الحالة
              if (!notification.isRead)
                Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'الآن';
        }
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
