import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    // TODO: Implement actual API call to load notifications
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    
    // Mock data for demonstration
    setState(() {
      _notifications = [
        {
          'id': '1',
          'title': 'تذكير بموعدك القادم',
          'body': 'لديك موعد غداً مع د. محمد أحمد في مستشفى الملك فهد الساعة 10:00 صباحاً',
          'type': 'appointment_reminder',
          'date': DateTime.now().subtract(const Duration(hours: 2)),
          'isRead': false,
          'data': {
            'appointmentId': '123',
          },
        },
        {
          'id': '2',
          'title': 'تم تأكيد موعدك',
          'body': 'تم تأكيد موعدك مع د. سارة خالد في مستشفى الأمل يوم الأحد القادم',
          'type': 'appointment_confirmation',
          'date': DateTime.now().subtract(const Duration(days: 1)),
          'isRead': true,
          'data': {
            'appointmentId': '456',
          },
        },
        {
          'id': '3',
          'title': 'تقرير طبي جديد',
          'body': 'تم إضافة تقرير طبي جديد من د. فيصل العمري',
          'type': 'medical_record',
          'date': DateTime.now().subtract(const Duration(days: 3)),
          'isRead': true,
          'data': {
            'medicalRecordId': '789',
          },
        },
        {
          'id': '4',
          'title': 'تذكير بتناول الدواء',
          'body': 'حان موعد تناول دواء أموكسيسيلين (500 ملغ)',
          'type': 'medication_reminder',
          'date': DateTime.now().subtract(const Duration(days: 4)),
          'isRead': true,
          'data': {
            'medicationId': '101',
          },
        },
        {
          'id': '5',
          'title': 'عرض خاص',
          'body': 'خصم 20% على الفحوصات الطبية في مستشفى الشفاء خلال شهر رمضان',
          'type': 'promotion',
          'date': DateTime.now().subtract(const Duration(days: 7)),
          'isRead': false,
          'data': {
            'promotionId': '202',
          },
        },
      ];
      
      _isLoading = false;
    });
  }

  Future<void> _markAsRead(String notificationId) async {
    // TODO: Implement actual API call to mark notification as read
    setState(() {
      final index = _notifications.indexWhere((n) => n['id'] == notificationId);
      if (index != -1) {
        _notifications[index]['isRead'] = true;
      }
    });
  }

  Future<void> _markAllAsRead() async {
    // TODO: Implement actual API call to mark all notifications as read
    setState(() {
      for (final notification in _notifications) {
        notification['isRead'] = true;
      }
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تعيين جميع الإشعارات كمقروءة')),
      );
    }
  }

  Future<void> _deleteNotification(String notificationId) async {
    // TODO: Implement actual API call to delete notification
    setState(() {
      _notifications.removeWhere((n) => n['id'] == notificationId);
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف الإشعار')),
      );
    }
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    // Mark as read
    _markAsRead(notification['id']);
    
    // Navigate based on notification type
    switch (notification['type']) {
      case 'appointment_reminder':
      case 'appointment_confirmation':
        // TODO: Navigate to appointment details
        // Navigator.pushNamed(
        //   context,
        //   '/appointment-details',
        //   arguments: notification['data']['appointmentId'],
        // );
        break;
      case 'medical_record':
        // TODO: Navigate to medical record details
        // Navigator.pushNamed(
        //   context,
        //   '/medical-record-details',
        //   arguments: notification['data']['medicalRecordId'],
        // );
        break;
      case 'medication_reminder':
        // TODO: Navigate to medication details
        // Navigator.pushNamed(
        //   context,
        //   '/medication-details',
        //   arguments: notification['data']['medicationId'],
        // );
        break;
      case 'promotion':
        // TODO: Navigate to promotion details
        // Navigator.pushNamed(
        //   context,
        //   '/promotion-details',
        //   arguments: notification['data']['promotionId'],
        // );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => n['isRead'] == false).length;
    
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
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_off,
                        size: 80.w,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'لا توجد إشعارات',
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.builder(
                    padding: EdgeInsets.all(8.w),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      return _buildNotificationCard(notification);
                    },
                  ),
                ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final isRead = notification['isRead'] as bool;
    final date = notification['date'] as DateTime;
    
    // Get icon based on notification type
    IconData iconData;
    Color iconColor;
    
    switch (notification['type']) {
      case 'appointment_reminder':
      case 'appointment_confirmation':
        iconData = Icons.calendar_today;
        iconColor = Colors.blue;
        break;
      case 'medical_record':
        iconData = Icons.medical_information;
        iconColor = Colors.green;
        break;
      case 'medication_reminder':
        iconData = Icons.medication;
        iconColor = Colors.orange;
        break;
      case 'promotion':
        iconData = Icons.local_offer;
        iconColor = Colors.purple;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = Colors.grey;
    }
    
    return Dismissible(
      key: Key(notification['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (direction) {
        _deleteNotification(notification['id']);
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
        elevation: isRead ? 1 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: isRead
              ? BorderSide.none
              : BorderSide(color: AppTheme.primaryGreen, width: 1),
        ),
        color: isRead ? null : Colors.blue[50],
        child: InkWell(
          onTap: () => _handleNotificationTap(notification),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor: iconColor.withOpacity(0.1),
                  child: Icon(
                    iconData,
                    color: iconColor,
                    size: 20.w,
                  ),
                ),
                SizedBox(width: 12.w),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification['title'],
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        notification['body'],
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        _formatDate(date),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Unread indicator
                if (!isRead)
                  Container(
                    width: 10.w,
                    height: 10.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      final dateFormat = DateFormat('yyyy/MM/dd', 'ar');
      return dateFormat.format(date);
    }
  }
}
