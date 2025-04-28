import 'dart:developer' as developer;
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_flutter;
import '../../../core/config/supabase_config.dart';

class DatabaseSetup {
  final supabase_flutter.SupabaseClient _supabase =
      supabase_flutter.Supabase.instance.client;

  /// التحقق من وجود جدول في قاعدة البيانات
  Future<bool> checkTableExists(String tableName) async {
    try {
      // محاولة استعلام بسيط من الجدول
      await _supabase.from(tableName).select('*').limit(1);
      developer.log('Table $tableName exists');
      return true;
    } catch (e) {
      // إذا كان الخطأ يتعلق بعدم وجود الجدول
      if (e.toString().contains('relation') &&
          e.toString().contains('does not exist')) {
        developer.log('Table $tableName does not exist');
        return false;
      }
      // إذا كان الخطأ لسبب آخر (مثل مشاكل الصلاحيات)، نفترض أن الجدول موجود
      developer.log('Error checking if table $tableName exists: $e');
      return true;
    }
  }

  /// إنشاء جدول المستخدمين
  Future<bool> createUsersTable() async {
    try {
      // التحقق من وجود الجدول أولاً
      bool exists = await checkTableExists(SupabaseConfig.usersTable);
      if (exists) {
        developer.log('Users table already exists');
        return true;
      }

      // محاولة إنشاء جدول المستخدمين باستخدام SQL
      final createTableSQL = '''
      CREATE TABLE IF NOT EXISTS users (
        id TEXT PRIMARY KEY,
        email TEXT UNIQUE NOT NULL,
        full_name TEXT,
        phone TEXT,
        gender TEXT,
        birth_date TEXT,
        profile_picture TEXT,
        national_id TEXT,
        role TEXT NOT NULL DEFAULT 'Patient',
        is_active BOOLEAN NOT NULL DEFAULT TRUE,
        created_at TEXT NOT NULL
      )
      ''';

      try {
        // تنفيذ استعلام SQL مباشرة
        await _supabase.rpc('exec_sql', params: {'query': createTableSQL});
        developer.log('Users table created successfully');
        return true;
      } catch (rpcError) {
        developer.log('Error creating users table: $rpcError');
        return false;
      }
    } catch (e) {
      developer.log('Error in createUsersTable: $e');
      return false;
    }
  }

  /// إنشاء جدول حسابات المستخدمين
  Future<bool> createUserAccountsTable() async {
    try {
      // التحقق من وجود الجدول أولاً
      bool exists = await checkTableExists('user_accounts');
      if (exists) {
        developer.log('User accounts table already exists');
        return true;
      }

      // محاولة إنشاء جدول حسابات المستخدمين باستخدام SQL
      final createTableSQL = '''
      CREATE TABLE IF NOT EXISTS user_accounts (
        id TEXT PRIMARY KEY,
        email TEXT UNIQUE NOT NULL,
        name_arabic TEXT,
        is_admin BOOLEAN NOT NULL DEFAULT FALSE,
        created_at TEXT NOT NULL
      )
      ''';

      try {
        // تنفيذ استعلام SQL مباشرة
        await _supabase.rpc('exec_sql', params: {'query': createTableSQL});
        developer.log('User accounts table created successfully');
        return true;
      } catch (rpcError) {
        developer.log('Error creating user accounts table: $rpcError');
        return false;
      }
    } catch (e) {
      developer.log('Error in createUserAccountsTable: $e');
      return false;
    }
  }

  /// إنشاء دالة SQL لجلب المستخدمين من جدول المصادقة
  Future<bool> createGetAuthUsersFunction() async {
    try {
      final createFunctionSQL = '''
      CREATE OR REPLACE FUNCTION get_auth_users()
      RETURNS SETOF json AS \$\$
      BEGIN
        RETURN QUERY SELECT
          json_build_object(
            'id', id,
            'email', email,
            'created_at', created_at
          )
        FROM auth.users
        ORDER BY created_at DESC;
      END;
      \$\$ LANGUAGE plpgsql SECURITY DEFINER;
      ''';

      try {
        // تنفيذ استعلام SQL مباشرة
        await _supabase.rpc('exec_sql', params: {'query': createFunctionSQL});
        developer.log('get_auth_users function created successfully');
        return true;
      } catch (rpcError) {
        developer.log('Error creating get_auth_users function: $rpcError');
        return false;
      }
    } catch (e) {
      developer.log('Error in createGetAuthUsersFunction: $e');
      return false;
    }
  }

  /// إعداد قاعدة البيانات بالكامل
  Future<bool> setupDatabase() async {
    bool usersTableCreated = await createUsersTable();
    bool userAccountsTableCreated = await createUserAccountsTable();
    bool functionCreated = await createGetAuthUsersFunction();

    return usersTableCreated && userAccountsTableCreated && functionCreated;
  }
}
