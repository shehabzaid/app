import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    // TODO: Implement actual notification loading from backend
    // This is just mock data for now
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _notifications = [
        {
          'id': '1',
          'title': 'تم تأكيد موعدك',
          'body': 'تم تأكيد موعدك مع الدكتور أحمد في مستشفى الملك فهد يوم الأربعاء 15 مارس الساعة 10:00 صباحاً',
          'type': 'appointment',
          'read': false,
          'created_at': DateTime.now().subtract(const Duration(hours: 2)),
        },
        {
          'id': '2',
          'title': 'تذكير بموعدك غداً',
          'body': 'تذكير بموعدك غداً مع الدكتور محمد في مستشفى الملك فيصل الساعة 2:30 مساءً',
          'type': 'reminder',
          'read': true,
          'created_at': DateTime.now().subtract(const Duration(days: 1)),
        },
        {
          'id': '3',
          'title': 'تم إضافة سجل طبي جديد',
          'body': 'قام الدكتور خالد بإضافة سجل طبي جديد لملفك الطبي',
          'type': 'medical_record',
          'read': false,
          'created_at': DateTime.now().subtract(const Duration(days: 3)),
        },
        {
          'id': '4',
          'title': 'تم إلغاء موعدك',
          'body': 'تم إلغاء موعدك مع الدكتور فهد في مستشفى الملك خالد يوم الخميس 23 مارس',
          'type': 'appointment',
          'read': true,
          'created_at': DateTime.now().subtract(const Duration(days: 5)),
        },
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        centerTitle: true,
        actions: [
          if (_notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _showClearAllDialog,
              tooltip: 'حذف جميع الإشعارات',
            ),
        ],
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

    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off,
              size: 64.sp,
              color: Colors.grey,
            ),
            SizedBox(height: 16.h),
            Text(
              'لا توجد إشعارات',
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView.builder(
        padding: EdgeInsets.all(8.w),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          return _buildNotificationCard(_notifications[index]);
        },
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final dateFormat = DateFormat('yyyy/MM/dd', 'ar');
    final timeFormat = DateFormat('HH:mm', 'ar');
    final date = notification['created_at'] as DateTime;
    final formattedDate = dateFormat.format(date);
    final formattedTime = timeFormat.format(date);

    IconData iconData;
    Color iconColor;

    switch (notification['type']) {
      case 'appointment':
        iconData = Icons.calendar_today;
        iconColor = Colors.blue;
        break;
      case 'reminder':
        iconData = Icons.alarm;
        iconColor = Colors.orange;
        break;
      case 'medical_record':
        iconData = Icons.medical_information;
        iconColor = Colors.green;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = Colors.grey;
    }

    return Card(
      margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
      elevation: notification['read'] ? 1 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: notification['read']
            ? BorderSide.none
            : BorderSide(color: AppTheme.primaryGreen, width: 1.w),
      ),
      child: InkWell(
        onTap: () => _markAsRead(notification['id']),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  iconData,
                  color: iconColor,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notification['title'],
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: notification['read']
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!notification['read'])
                          Container(
                            width: 8.w,
                            height: 8.w,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      notification['body'],
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '$formattedDate - $formattedTime',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _markAsRead(String notificationId) {
    setState(() {
      final index = _notifications.indexWhere((n) => n['id'] == notificationId);
      if (index != -1) {
        _notifications[index]['read'] = true;
      }
    });

    // TODO: Implement actual marking as read in backend
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف جميع الإشعارات'),
        content: const Text('هل أنت متأكد من حذف جميع الإشعارات؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _notifications.clear();
              });
              // TODO: Implement actual clearing in backend
            },
            child: const Text(
              'حذف',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
