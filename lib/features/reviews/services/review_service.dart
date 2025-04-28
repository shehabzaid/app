import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;
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
  Future<void> addReview(Review review) async {
    try {
      await _supabase.from(SupabaseConfig.reviewsTable).insert(review.toJson());
    } catch (e) {
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

  // حساب متوسط تقييم طبيب
  Future<double> getDoctorAverageRating(String doctorId) async {
    try {
      final reviews = await getDoctorReviews(doctorId);

      if (reviews.isEmpty) {
        return 0.0;
      }

      final totalRating =
          reviews.fold(0, (sum, review) => sum + review.rating);
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
