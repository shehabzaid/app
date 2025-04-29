import 'dart:developer' as developer;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/advertisement.dart';
import '../../../core/config/supabase_config.dart';

class AdvertisementService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _advertisementsTable = SupabaseConfig.advertisementsTable;

  // Cache for advertisements data
  final List<Advertisement> _adsCache = [];
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

  // جلب جميع الإعلانات النشطة
  Future<List<Advertisement>> getActiveAdvertisements() async {
    try {
      // Check if cache is valid
      if (_lastCacheUpdate != null &&
          DateTime.now().difference(_lastCacheUpdate!) < _cacheDuration &&
          _adsCache.isNotEmpty) {
        developer.log('Returning advertisements from cache');
        return _adsCache;
      }

      return await _retryOperation(() async {
        developer.log('Fetching advertisements from network...');

        final response = await _supabase
            .from(_advertisementsTable)
            .select()
            .eq('is_active', true)
            .lte('start_date', DateTime.now().toIso8601String())
            .or('end_date.is.null,end_date.gte.${DateTime.now().toIso8601String()}')
            .order('created_at', ascending: false);

        developer.log('Advertisements response received');

        if (response == null) {
          developer.log('Response is null');
          return [];
        }

        final advertisements = (response as List)
            .map((json) => Advertisement.fromJson(json))
            .toList();

        // Update cache
        _adsCache.clear();
        _adsCache.addAll(advertisements);
        _lastCacheUpdate = DateTime.now();

        return advertisements;
      });
    } catch (e, stackTrace) {
      developer.log('Error fetching advertisements: $e');
      developer.log('Stack trace: $stackTrace');

      // If we have cached data, return it even if it's expired
      if (_adsCache.isNotEmpty) {
        developer.log('Returning stale cache due to error');
        return _adsCache;
      }

      // If no cache available, return empty list
      return [];
    }
  }

  // إضافة إعلان جديد (للمشرفين فقط)
  Future<void> addAdvertisement(Advertisement advertisement) async {
    try {
      await _supabase.from(_advertisementsTable).insert(advertisement.toJson());

      // Clear cache to force refresh
      _adsCache.clear();
      _lastCacheUpdate = null;
    } catch (e) {
      throw Exception('فشل في إضافة الإعلان: $e');
    }
  }

  // تحديث إعلان (للمشرفين فقط)
  Future<void> updateAdvertisement(Advertisement advertisement) async {
    try {
      await _supabase
          .from(_advertisementsTable)
          .update(advertisement.toJson())
          .eq('id', advertisement.id);

      // Clear cache to force refresh
      _adsCache.clear();
      _lastCacheUpdate = null;
    } catch (e) {
      throw Exception('فشل في تحديث الإعلان: $e');
    }
  }

  // جلب جميع الإعلانات (للمشرفين فقط)
  Future<List<Advertisement>> getAllAdvertisements() async {
    try {
      return await _retryOperation(() async {
        developer.log('Fetching all advertisements for admin...');

        final response = await _supabase
            .from(_advertisementsTable)
            .select()
            .order('created_at', ascending: false);

        developer.log('All advertisements response received');

        if (response == null) {
          developer.log('Response is null');
          return [];
        }

        final advertisements = (response as List)
            .map((json) => Advertisement.fromJson(json))
            .toList();

        return advertisements;
      });
    } catch (e, stackTrace) {
      developer.log('Error fetching all advertisements: $e');
      developer.log('Stack trace: $stackTrace');
      throw Exception('فشل في جلب قائمة الإعلانات: $e');
    }
  }

  // الحصول على إعلان محدد بواسطة المعرف
  Future<Advertisement> getAdvertisementById(String id) async {
    try {
      final response = await _supabase
          .from(_advertisementsTable)
          .select()
          .eq('id', id)
          .single();

      return Advertisement.fromJson(response);
    } catch (e) {
      throw Exception('فشل في جلب تفاصيل الإعلان: $e');
    }
  }

  // حذف إعلان (للمشرفين فقط)
  Future<void> deleteAdvertisement(String id) async {
    try {
      await _supabase.from(_advertisementsTable).delete().eq('id', id);

      // Clear cache to force refresh
      _adsCache.clear();
      _lastCacheUpdate = null;
    } catch (e) {
      throw Exception('فشل في حذف الإعلان: $e');
    }
  }
}
