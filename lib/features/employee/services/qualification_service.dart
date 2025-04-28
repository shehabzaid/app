import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/qualification.dart';

class QualificationService {
  final supabase = Supabase.instance.client;
  static const String bucketName = 'qualifications';

  Future<List<Qualification>> getQualifications(String employeeId) async {
    try {
      final response = await supabase
          .from('qualifications')
          .select()
          .eq('employee_id', employeeId)
          .order('created_at');

      return (response as List)
          .map((json) => Qualification.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('فشل في تحميل المؤهلات: ${e.toString()}');
    }
  }

  Future<void> addQualification(Qualification qualification) async {
    try {
      await supabase.from('qualifications').insert(qualification.toJson());
    } catch (e) {
      throw Exception('فشل في إضافة المؤهل: ${e.toString()}');
    }
  }

  Future<void> updateQualification(Qualification qualification) async {
    try {
      await supabase
          .from('qualifications')
          .update(qualification.toJson())
          .eq('id', qualification.id);
    } catch (e) {
      throw Exception('فشل في تحديث المؤهل: ${e.toString()}');
    }
  }

  Future<void> deleteQualification(String id) async {
    try {
      await supabase.from('qualifications').delete().eq('id', id);
    } catch (e) {
      throw Exception('فشل في حذف المؤهل: ${e.toString()}');
    }
  }

  Future<String> uploadQualificationFile(
      String filePath, String employeeId) async {
    try {
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('يجب تسجيل الدخول لرفع الملفات');
      }

      final file = File(filePath);
      final fileExt = filePath.split('.').last.toLowerCase();
      final fileName =
          '${DateTime.now().toIso8601String()}_${currentUser.id}.$fileExt';

      // رفع الملف في مجلد خاص بالموظف
      final storagePath = '$employeeId/$fileName';
      await supabase.storage.from(bucketName).upload(
            storagePath,
            file,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      final String fileUrl =
          supabase.storage.from(bucketName).getPublicUrl(storagePath);
      return fileUrl;
    } catch (e) {
      if (e.toString().contains('Bucket not found')) {
        throw Exception(
            'المجلد غير موجود في التخزين. يرجى إنشاء مجلد qualifications');
      }
      throw Exception('فشل في رفع الملف: ${e.toString()}');
    }
  }
}
