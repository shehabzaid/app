import 'dart:developer' as developer;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';
import '../../../core/config/supabase_config.dart';

class NotificationService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _notificationsTable = SupabaseConfig.notificationsTable;

  // Cache for notifications data
  final List<NotificationModel> _notificationsCache = [];
  DateTime? _lastCacheUpdate;
  static const _cacheDuration = Duration(minutes: 5);

  // Retry configuration
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 1);

  // Helper method for retrying operations
  Future<T> _retryOperation<T>(Future<T> Function() operation) async {
    int attempts = 0;
    while (attempts < _maxRetries) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        developer.log('Operation failed (attempt $attempts): $e');
        if (attempts >= _maxRetries) rethrow;
        await Future.delayed(_retryDelay * attempts);
      }
    }
    throw Exception('Failed after $_maxRetries attempts');
  }

  // إضافة إشعار جديد
  Future<void> addNotification(String userId, String title, String body,
      {String? type, String? referenceId}) async {
    try {
      await _retryOperation(() async {
        developer.log('Adding notification for user: $userId');

        final notification = {
          'user_id': userId,
          'title': title,
          'body': body,
          'type': type,
          'reference_id': referenceId,
          'is_read': false,
          'created_at': DateTime.now().toIso8601String(),
        };

        await _supabase.from(_notificationsTable).insert(notification);

        developer.log('Notification added successfully');

        // Clear cache to force refresh
        _notificationsCache.clear();
        _lastCacheUpdate = null;
      });
    } catch (e, stackTrace) {
      developer.log('Error adding notification: $e');
      developer.log('Stack trace: $stackTrace');
      throw Exception('فشل في إضافة الإشعار: $e');
    }
  }

  // جلب إشعارات المستخدم
  Future<List<NotificationModel>> getUserNotifications(String userId,
      {bool forceRefresh = false}) async {
    try {
      // Check if cache is valid
      if (!forceRefresh &&
          _lastCacheUpdate != null &&
          DateTime.now().difference(_lastCacheUpdate!) < _cacheDuration &&
          _notificationsCache.isNotEmpty) {
        developer.log('Returning notifications from cache');
        return _notificationsCache
            .where((notification) => notification.userId == userId)
            .toList();
      }

      return await _retryOperation(() async {
        developer.log('Fetching notifications for user: $userId');

        final response = await _supabase
            .from(_notificationsTable)
            .select()
            .eq('user_id', userId)
            .order('created_at', ascending: false);

        developer.log('Notifications response received');

        final notifications = (response as List)
            .map((json) => NotificationModel.fromJson(json))
            .toList();

        // Update cache
        _notificationsCache.clear();
        _notificationsCache.addAll(notifications);
        _lastCacheUpdate = DateTime.now();

        return notifications;
      });
    } catch (e, stackTrace) {
      developer.log('Error fetching notifications: $e');
      developer.log('Stack trace: $stackTrace');
      throw Exception('فشل في جلب الإشعارات: $e');
    }
  }

  // تحديث حالة قراءة الإشعار
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _retryOperation(() async {
        developer.log('Marking notification as read: $notificationId');

        await _supabase
            .from(_notificationsTable)
            .update({'is_read': true}).eq('id', notificationId);

        developer.log('Notification marked as read successfully');

        // Update cache
        final index = _notificationsCache
            .indexWhere((notification) => notification.id == notificationId);
        if (index != -1) {
          _notificationsCache[index] =
              _notificationsCache[index].copyWith(isRead: true);
        }
      });
    } catch (e, stackTrace) {
      developer.log('Error marking notification as read: $e');
      developer.log('Stack trace: $stackTrace');
      throw Exception('فشل في تحديث حالة قراءة الإشعار: $e');
    }
  }

  // تحديث حالة قراءة جميع إشعارات المستخدم
  Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      await _retryOperation(() async {
        developer.log('Marking all notifications as read for user: $userId');

        await _supabase
            .from(_notificationsTable)
            .update({'is_read': true})
            .eq('user_id', userId)
            .eq('is_read', false);

        developer.log('All notifications marked as read successfully');

        // Update cache
        for (int i = 0; i < _notificationsCache.length; i++) {
          if (_notificationsCache[i].userId == userId &&
              !_notificationsCache[i].isRead) {
            _notificationsCache[i] =
                _notificationsCache[i].copyWith(isRead: true);
          }
        }
      });
    } catch (e, stackTrace) {
      developer.log('Error marking all notifications as read: $e');
      developer.log('Stack trace: $stackTrace');
      throw Exception('فشل في تحديث حالة قراءة جميع الإشعارات: $e');
    }
  }

  // حذف إشعار
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _retryOperation(() async {
        developer.log('Deleting notification: $notificationId');

        await _supabase
            .from(_notificationsTable)
            .delete()
            .eq('id', notificationId);

        developer.log('Notification deleted successfully');

        // Update cache
        _notificationsCache
            .removeWhere((notification) => notification.id == notificationId);
      });
    } catch (e, stackTrace) {
      developer.log('Error deleting notification: $e');
      developer.log('Stack trace: $stackTrace');
      throw Exception('فشل في حذف الإشعار: $e');
    }
  }

  // جلب عدد الإشعارات غير المقروءة
  Future<int> getUnreadNotificationsCount(String userId) async {
    try {
      // Check if cache is valid
      if (_lastCacheUpdate != null &&
          DateTime.now().difference(_lastCacheUpdate!) < _cacheDuration &&
          _notificationsCache.isNotEmpty) {
        developer.log('Returning unread count from cache');
        return _notificationsCache
            .where((notification) =>
                notification.userId == userId && !notification.isRead)
            .length;
      }

      return await _retryOperation(() async {
        developer.log('Fetching unread notifications count for user: $userId');

        final response = await _supabase
            .from(_notificationsTable)
            .select('id')
            .eq('user_id', userId)
            .eq('is_read', false);

        developer.log('Unread count response received');

        return (response as List).length;
      });
    } catch (e, stackTrace) {
      developer.log('Error fetching unread notifications count: $e');
      developer.log('Stack trace: $stackTrace');
      return 0; // Return 0 in case of error
    }
  }

  // جلب جميع الإشعارات (للمشرفين)
  Future<List<NotificationModel>> getAllNotifications(
      {bool forceRefresh = false}) async {
    try {
      // Check if cache is valid
      if (!forceRefresh &&
          _lastCacheUpdate != null &&
          DateTime.now().difference(_lastCacheUpdate!) < _cacheDuration &&
          _notificationsCache.isNotEmpty) {
        developer.log('Returning all notifications from cache');
        return List.from(_notificationsCache);
      }

      return await _retryOperation(() async {
        developer.log('Fetching all notifications');

        final response = await _supabase
            .from(_notificationsTable)
            .select()
            .order('created_at', ascending: false);

        developer.log('All notifications response received');

        final notifications = (response as List)
            .map((json) => NotificationModel.fromJson(json))
            .toList();

        // Update cache
        _notificationsCache.clear();
        _notificationsCache.addAll(notifications);
        _lastCacheUpdate = DateTime.now();

        return notifications;
      });
    } catch (e, stackTrace) {
      developer.log('Error fetching all notifications: $e');
      developer.log('Stack trace: $stackTrace');
      throw Exception('فشل في جلب جميع الإشعارات: $e');
    }
  }

  // حذف جميع الإشعارات (للمشرفين)
  Future<void> deleteAllNotifications() async {
    try {
      await _retryOperation(() async {
        developer.log('Deleting all notifications');

        // هذا يحذف جميع الإشعارات - استخدم بحذر
        await _supabase
            .from(_notificationsTable)
            .delete()
            .neq('id', '0'); // شرط دائمًا صحيح لحذف جميع السجلات

        developer.log('All notifications deleted successfully');

        // Clear cache
        _notificationsCache.clear();
        _lastCacheUpdate = null;
      });
    } catch (e, stackTrace) {
      developer.log('Error deleting all notifications: $e');
      developer.log('Stack trace: $stackTrace');
      throw Exception('فشل في حذف جميع الإشعارات: $e');
    }
  }

  // إرسال إشعار لجميع المستخدمين
  Future<void> sendNotificationToAllUsers({
    required String title,
    required String body,
    String? type,
    String? referenceId,
  }) async {
    try {
      await _retryOperation(() async {
        developer.log('Sending notification to all users');

        // جلب جميع المستخدمين
        final response = await _supabase.from('users').select('id');
        final userIds =
            (response as List).map((user) => user['id'] as String).toList();

        developer.log('Found ${userIds.length} users to notify');

        // إرسال الإشعار لكل مستخدم
        for (final userId in userIds) {
          await addNotification(userId, title, body,
              type: type, referenceId: referenceId);
        }

        developer.log('Notification sent to all users successfully');
      });
    } catch (e, stackTrace) {
      developer.log('Error sending notification to all users: $e');
      developer.log('Stack trace: $stackTrace');
      throw Exception('فشل في إرسال الإشعار لجميع المستخدمين: $e');
    }
  }
}
