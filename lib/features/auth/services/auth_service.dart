import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // تسجيل مستخدم جديد بطريقة ذكية
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    String? gender,
    DateTime? birthDate,
    String? nationalId,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('فشل إنشاء الحساب');
      }

      final userId = response.user!.id;
      final now = DateTime.now().toIso8601String();

      // إدخال في جدول users
      try {
        final existingUser = await _supabase
            .from('users')
            .select('id')
            .eq('id', userId)
            .maybeSingle();

        if (existingUser == null) {
          await _supabase.from('users').insert({
            'id': userId,
            'email': email,
            'full_name': fullName,
            'phone': phone,
            'gender': gender ?? '',
            'birth_date': birthDate?.toIso8601String(),
            'profile_picture': null,
            'national_id': nationalId ?? '',
            'role': 'Patient',
            'is_active': true,
            'created_at': now,
          });
        } else {
          print('المستخدم موجود بالفعل في جدول users');
        }
      } catch (e) {
        throw Exception('خطأ أثناء إدخال بيانات جدول users: ${e.toString()}');
      }

      // إدخال في جدول user_accounts
      try {
        final existingAccount = await _supabase
            .from('user_accounts')
            .select('id')
            .eq('id', userId)
            .maybeSingle();

        if (existingAccount == null) {
          await _supabase.from('user_accounts').insert({
            'id': userId,
            'email': email,
            'name_arbic': fullName,
            'is_admin': false,
            'created_at': now,
          });
        } else {
          print('المستخدم موجود بالفعل في جدول user_accounts');
        }
      } catch (e) {
        throw Exception(
            'خطأ أثناء إدخال بيانات جدول user_accounts: ${e.toString()}');
      }

      // إدخال في جدول profiles
      try {
        final existingProfile = await _supabase
            .from('profiles')
            .select('id')
            .eq('id', userId)
            .maybeSingle();

        if (existingProfile == null) {
          await _supabase.from('profiles').insert({
            'id': userId,
            'full_name': fullName,
            'phone': phone,
            'national_id': nationalId ?? '',
            'created_at': now,
            'updated_at': now,
          });
        } else {
          print('المستخدم موجود بالفعل في جدول profiles');
        }
      } catch (e) {
        throw Exception(
            'خطأ أثناء إدخال بيانات جدول profiles: ${e.toString()}');
      }
    } on AuthException catch (e) {
      throw Exception('خطأ أثناء تسجيل الحساب: ${e.message}');
    } catch (e) {
      throw Exception('خطأ عام أثناء التسجيل: ${e.toString()}');
    }
  }

  // باقي الدوال كما هي ✅

  Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception("لم يتم العثور على بيانات المستخدم");
      }

      final userData = await _supabase
          .from('users')
          .select()
          .eq('id', response.user!.id)
          .maybeSingle();

      if (userData == null) {
        throw Exception('بيانات المستخدم غير موجودة');
      }

      final userProfile = UserProfile.fromJson(userData);

      return {
        'user': {
          'id': response.user!.id,
          'email': response.user!.email!,
        },
        'role': userProfile.role,
        'userProfile': userProfile,
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<List<UserProfile>> getAllUsers() async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => UserProfile.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('فشل في جلب قائمة المستخدمين: $e');
    }
  }

  Future<Map<String, dynamic>?> getSession() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) return null;

      final userData = await _supabase
          .from('users')
          .select()
          .eq('id', session.user.id)
          .maybeSingle();

      if (userData == null) return null;

      final userProfile = UserProfile.fromJson(userData);

      return {
        'user': {
          'id': session.user.id,
          'email': session.user.email!,
        },
        'role': userProfile.role,
        'userProfile': userProfile,
      };
    } catch (e) {
      return null;
    }
  }

  Future<UserProfile?> getCurrentUserProfile() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final userData =
          await _supabase.from('users').select().eq('id', userId).maybeSingle();

      if (userData == null) return null;

      return UserProfile.fromJson(userData);
    } catch (e) {
      return null;
    }
  }

  Future<UserProfile?> getUserProfileById(String userId) async {
    try {
      final userData =
          await _supabase.from('users').select().eq('id', userId).maybeSingle();

      if (userData == null) return null;

      return UserProfile.fromJson(userData);
    } catch (e) {
      throw Exception('فشل في جلب بيانات المستخدم: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> adminLogout() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  // تحديث دور المستخدم
  Future<void> updateUserRole(String userId, String newRole) async {
    try {
      await _supabase.from('users').update({'role': newRole}).eq('id', userId);
    } catch (e) {
      throw Exception('فشل في تحديث دور المستخدم: $e');
    }
  }

  // تحديث حالة المستخدم (تفعيل/تعطيل)
  Future<void> updateUserStatus(String userId, bool isActive) async {
    try {
      await _supabase
          .from('users')
          .update({'is_active': isActive}).eq('id', userId);
    } catch (e) {
      throw Exception('فشل في تحديث حالة المستخدم: $e');
    }
  }

  // حذف حساب مستخدم
  Future<void> deleteUser(String userId) async {
    try {
      // حذف من جدول users
      await _supabase.from('users').delete().eq('id', userId);

      // حذف من جدول auth.users (يتطلب صلاحيات خاصة)
      // هذا يتطلب وظيفة خاصة في Supabase
      // await _supabase.rpc('delete_auth_user', { 'user_id': userId });
    } catch (e) {
      throw Exception('فشل في حذف حساب المستخدم: $e');
    }
  }
}
