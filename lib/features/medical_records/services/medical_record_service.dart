import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;
import '../../../core/config/supabase_config.dart';
import '../models/medical_record.dart';
import 'dart:io';

class MedicalRecordService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // جلب السجلات الطبية للمريض
  Future<List<MedicalRecord>> getPatientMedicalRecords(String patientId) async {
    try {
      developer.log('Fetching medical records for patient: $patientId');

      final response = await _supabase
          .from(SupabaseConfig.medicalRecordsTable)
          .select()
          .eq('patient_id', patientId)
          .order('created_at', ascending: false);

      developer.log('Medical records response received');

      return (response as List)
          .map((json) => MedicalRecord.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      developer.log('Error fetching medical records: $e');
      developer.log('Stack trace: $stackTrace');
      throw Exception('فشل في جلب السجلات الطبية: $e');
    }
  }

  // جلب السجلات الطبية التي أضافها الطبيب
  Future<List<MedicalRecord>> getDoctorMedicalRecords(String doctorId) async {
    try {
      developer.log('Fetching medical records for doctor: $doctorId');

      final response = await _supabase
          .from(SupabaseConfig.medicalRecordsTable)
          .select()
          .eq('doctor_id', doctorId)
          .order('created_at', ascending: false);

      developer.log('Medical records response received');

      return (response as List)
          .map((json) => MedicalRecord.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      developer.log('Error fetching medical records: $e');
      developer.log('Stack trace: $stackTrace');
      throw Exception('فشل في جلب السجلات الطبية: $e');
    }
  }

  // جلب تفاصيل سجل طبي محدد
  Future<MedicalRecord> getMedicalRecordDetails(String recordId) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.medicalRecordsTable)
          .select()
          .eq('id', recordId)
          .single();

      return MedicalRecord.fromJson(response);
    } catch (e) {
      throw Exception('فشل في جلب تفاصيل السجل الطبي: $e');
    }
  }

  // إضافة سجل طبي جديد
  Future<void> addMedicalRecord(MedicalRecord record) async {
    try {
      await _supabase
          .from(SupabaseConfig.medicalRecordsTable)
          .insert(record.toJson());
    } catch (e) {
      throw Exception('فشل في إضافة السجل الطبي: $e');
    }
  }

  // تحديث سجل طبي
  Future<void> updateMedicalRecord(MedicalRecord record) async {
    try {
      await _supabase
          .from(SupabaseConfig.medicalRecordsTable)
          .update(record.toJson())
          .eq('id', record.id);
    } catch (e) {
      throw Exception('فشل في تحديث السجل الطبي: $e');
    }
  }

  // حذف سجل طبي
  Future<void> deleteMedicalRecord(String recordId) async {
    try {
      await _supabase
          .from(SupabaseConfig.medicalRecordsTable)
          .delete()
          .eq('id', recordId);
    } catch (e) {
      throw Exception('فشل في حذف السجل الطبي: $e');
    }
  }

  // رفع مرفقات للسجل الطبي
  Future<List<String>> uploadAttachments(
      String recordId, List<String> filePaths) async {
    try {
      List<String> uploadedUrls = [];

      for (var filePath in filePaths) {
        final fileName = filePath.split('/').last;
        final fileExt = fileName.split('.').last;
        final path =
            'medical_records/$recordId/${DateTime.now().millisecondsSinceEpoch}.$fileExt';

        final response = await _supabase.storage
            .from('medical_records')
            .upload(path, File(filePath));

        final fileUrl =
            _supabase.storage.from('medical_records').getPublicUrl(path);

        uploadedUrls.add(fileUrl);
      }

      // تحديث السجل الطبي بروابط المرفقات
      final record = await getMedicalRecordDetails(recordId);
      final updatedAttachments = [
        ...(record.attachmentsUrls ?? []),
        ...uploadedUrls
      ];

      await _supabase
          .from(SupabaseConfig.medicalRecordsTable)
          .update({'attachments_urls': updatedAttachments}).eq('id', recordId);

      return uploadedUrls;
    } catch (e) {
      throw Exception('فشل في رفع المرفقات: $e');
    }
  }

  // حذف مرفق من السجل الطبي
  Future<void> deleteAttachment(String recordId, String attachmentUrl) async {
    try {
      // الحصول على السجل الطبي
      final record = await getMedicalRecordDetails(recordId);

      // حذف المرفق من قائمة المرفقات
      final updatedAttachments = record.attachmentsUrls
              ?.where((url) => url != attachmentUrl)
              .toList() ??
          [];

      // تحديث السجل الطبي
      await _supabase
          .from(SupabaseConfig.medicalRecordsTable)
          .update({'attachments_urls': updatedAttachments}).eq('id', recordId);

      // حذف الملف من التخزين
      final path = attachmentUrl.split('medical_records/').last;
      await _supabase.storage.from('medical_records').remove([path]);
    } catch (e) {
      throw Exception('فشل في حذف المرفق: $e');
    }
  }
}
