import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;
import 'package:uuid/uuid.dart';
import '../../../core/config/supabase_config.dart';
import '../models/review.dart';

class ReviewService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // جلب تقييمات طبيب محدد
  Future<List<Review>> getDoctorReviews(String doctorId) async {
    try {
      developer.log('Fetching reviews for doctor: $doctorId');

      final response = await _supabase
          .from(SupabaseConfig.reviewsTable)
          .select()
          .eq('doctor_id', doctorId)
          .order('created_at', ascending: false);

      developer.log('Reviews response received');

      return (response as List).map((json) => Review.fromJson(json)).toList();
    } catch (e, stackTrace) {
      developer.log('Error fetching reviews: $e');
      developer.log('Stack trace: $stackTrace');
      throw Exception('فشل في جلب التقييمات: $e');
    }
  }

  // جلب تقييمات مريض محدد
  Future<List<Review>> getPatientReviews(String patientId) async {
    try {
      developer.log('Fetching reviews for patient: $patientId');

      final response = await _supabase
          .from(SupabaseConfig.reviewsTable)
          .select()
          .eq('patient_id', patientId)
          .order('created_at', ascending: false);

      developer.log('Reviews response received');

      return (response as List).map((json) => Review.fromJson(json)).toList();
    } catch (e, stackTrace) {
      developer.log('Error fetching reviews: $e');
      developer.log('Stack trace: $stackTrace');
      throw Exception('فشل في جلب التقييمات: $e');
    }
  }

  // إضافة تقييم جديد
  Future<Review> addReview(Review review) async {
    try {
      // إنشاء معرف فريد للتقييم إذا لم يكن موجودًا
      final reviewData = review.toJson();
      if (reviewData['id'] == null || reviewData['id'].toString().isEmpty) {
        reviewData['id'] = const Uuid().v4();
      }

      // إضافة تاريخ التحديث
      reviewData['updated_at'] = DateTime.now().toIso8601String();

      try {
        await _supabase.from(SupabaseConfig.reviewsTable).insert(reviewData);
      } catch (e) {
        // إذا كان الخطأ بسبب عدم وجود عمود appointment_id، نحذفه من البيانات ونحاول مرة أخرى
        if (e.toString().contains('column "appointment_id" does not exist')) {
          developer.log(
              'Column appointment_id does not exist in reviews table, removing it from data');
          reviewData.remove('appointment_id');
          await _supabase.from(SupabaseConfig.reviewsTable).insert(reviewData);
        } else {
          // إعادة رمي الخطأ إذا كان لسبب آخر
          rethrow;
        }
      }

      // إرجاع التقييم مع المعرف الجديد
      return Review.fromJson(reviewData);
    } catch (e) {
      developer.log('Error adding review: $e');
      throw Exception('فشل في إضافة التقييم: $e');
    }
  }

  // تحديث تقييم
  Future<void> updateReview(Review review) async {
    try {
      await _supabase
          .from(SupabaseConfig.reviewsTable)
          .update(review.toJson())
          .eq('id', review.id);
    } catch (e) {
      throw Exception('فشل في تحديث التقييم: $e');
    }
  }

  // حذف تقييم
  Future<void> deleteReview(String reviewId) async {
    try {
      await _supabase
          .from(SupabaseConfig.reviewsTable)
          .delete()
          .eq('id', reviewId);
    } catch (e) {
      throw Exception('فشل في حذف التقييم: $e');
    }
  }

  // التحقق من وجود تقييم للمريض لطبيب محدد
  Future<bool> hasPatientReviewedDoctor(
      String patientId, String doctorId) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.reviewsTable)
          .select('id')
          .eq('patient_id', patientId)
          .eq('doctor_id', doctorId);

      return (response as List).isNotEmpty;
    } catch (e) {
      throw Exception('فشل في التحقق من وجود تقييم: $e');
    }
  }

  // التحقق من وجود تقييم لموعد محدد
  Future<bool> hasAppointmentBeenReviewed(String appointmentId) async {
    try {
      // التحقق من وجود عمود appointment_id في الجدول
      try {
        final response = await _supabase
            .from(SupabaseConfig.reviewsTable)
            .select('id')
            .eq('appointment_id', appointmentId);

        return (response as List).isNotEmpty;
      } catch (e) {
        // إذا كان الخطأ بسبب عدم وجود العمود، نفترض أنه لا يوجد تقييم
        if (e.toString().contains('column "appointment_id" does not exist')) {
          developer
              .log('Column appointment_id does not exist in reviews table');
          return false;
        }
        // إعادة رمي الخطأ إذا كان لسبب آخر
        rethrow;
      }
    } catch (e) {
      developer.log('Error checking if appointment has been reviewed: $e');
      // بدلاً من رمي استثناء، نعيد false لتجنب توقف التطبيق
      return false;
    }
  }

  // جلب تقييم موعد محدد
  Future<Review?> getAppointmentReview(String appointmentId) async {
    try {
      // التحقق من وجود عمود appointment_id في الجدول
      try {
        final response = await _supabase
            .from(SupabaseConfig.reviewsTable)
            .select()
            .eq('appointment_id', appointmentId)
            .maybeSingle();

        if (response == null) return null;

        return Review.fromJson(response);
      } catch (e) {
        // إذا كان الخطأ بسبب عدم وجود العمود، نعيد null
        if (e.toString().contains('column "appointment_id" does not exist')) {
          developer
              .log('Column appointment_id does not exist in reviews table');
          return null;
        }
        // إعادة رمي الخطأ إذا كان لسبب آخر
        rethrow;
      }
    } catch (e) {
      developer.log('Error fetching appointment review: $e');
      // بدلاً من رمي استثناء، نعيد null لتجنب توقف التطبيق
      return null;
    }
  }

  // حساب متوسط تقييم طبيب
  Future<double> getDoctorAverageRating(String doctorId) async {
    try {
      final reviews = await getDoctorReviews(doctorId);

      if (reviews.isEmpty) {
        return 0.0;
      }

      final totalRating = reviews.fold(0, (sum, review) => sum + review.rating);
      return totalRating / reviews.length;
    } catch (e) {
      throw Exception('فشل في حساب متوسط التقييم: $e');
    }
  }

  // الحصول على عدد التقييمات لكل درجة (1-5) لطبيب محدد
  Future<Map<int, int>> getDoctorRatingDistribution(String doctorId) async {
    try {
      final reviews = await getDoctorReviews(doctorId);

      Map<int, int> distribution = {
        1: 0,
        2: 0,
        3: 0,
        4: 0,
        5: 0,
      };

      for (var review in reviews) {
        distribution[review.rating] = (distribution[review.rating] ?? 0) + 1;
      }

      return distribution;
    } catch (e) {
      throw Exception('فشل في حساب توزيع التقييمات: $e');
    }
  }
}
