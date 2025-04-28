import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/identity_card.dart';
import 'dart:io';

class IdentityCardService {
  final supabase = Supabase.instance.client;
  static const String bucketName = 'identity-cards';

  Future<List<IdentityCard>> getIdentityCards(String employeeId) async {
    try {
      final response = await supabase
          .from('identity_cards')
          .select()
          .eq('employee_id', employeeId)
          .order('created_at');

      return (response as List)
          .map((json) => IdentityCard.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('فشل في تحميل البطاقات: ${e.toString()}');
    }
  }

  Future<void> addIdentityCard(IdentityCard card) async {
    try {
      await supabase.from('identity_cards').insert(card.toJson());
    } catch (e) {
      throw Exception('فشل في إضافة البطاقة: ${e.toString()}');
    }
  }

  Future<void> updateIdentityCard(IdentityCard card) async {
    try {
      await supabase
          .from('identity_cards')
          .update(card.toJson())
          .eq('id', card.id);
    } catch (e) {
      throw Exception('فشل في تحديث البطاقة: ${e.toString()}');
    }
  }

  Future<void> deleteIdentityCard(String id) async {
    try {
      await supabase.from('identity_cards').delete().eq('id', id);
    } catch (e) {
      throw Exception('فشل في حذف البطاقة: ${e.toString()}');
    }
  }

  Future<String> uploadCardImage(String filePath) async {
    try {
      // التحقق من وجود مستخدم مسجل دخوله
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('يجب تسجيل الدخول لرفع الملفات');
      }

      final file = File(filePath);
      final fileExt = filePath.split('.').last.toLowerCase();
      final fileName =
          '${DateTime.now().toIso8601String()}_${currentUser.id}.$fileExt';

      // رفع الملف
      await supabase.storage.from(bucketName).upload(
            'cards/$fileName',
            file,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      // الحصول على الرابط العام
      final String fileUrl =
          supabase.storage.from(bucketName).getPublicUrl('cards/$fileName');

      return fileUrl;
    } catch (e) {
      if (e.toString().contains('Bucket not found')) {
        throw Exception(
            'المجلد غير موجود في التخزين. يرجى إنشاء مجلد identity-cards');
      }
      throw Exception('فشل في رفع الصورة: ${e.toString()}');
    }
  }
}
