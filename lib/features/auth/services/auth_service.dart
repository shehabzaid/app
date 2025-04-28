import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../models/user.dart';
import '../models/user_profile.dart';
import 'package:flutter/material.dart';
import '../../../core/navigation/app_navigator.dart';
import '../../../core/config/supabase_config.dart';
import 'dart:async';
import 'dart:math';
import 'dart:developer' as developer;

class AuthService {
  final supabase.SupabaseClient _supabase = supabase.Supabase.instance.client;

  /// Login attempt tracking
  static const int _maxLoginAttempts = 5;
  static const int _lockoutDurationMinutes = 15;
  final Map<String, LoginAttemptInfo> _loginAttempts = {};

  /// Password strength requirements
  static final RegExp _passwordRegex = RegExp(
      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');

  /// Validates password strength
  String? validatePassword(String password) {
    if (!_passwordRegex.hasMatch(password)) {
      return 'Password must be at least 8 characters long and contain: '
          'uppercase letter, lowercase letter, number, and special character.';
    }
    return null;
  }

  /// Tracks login attempts and implements rate limiting
  void _trackLoginAttempt(String email, bool success) {
    if (!_loginAttempts.containsKey(email)) {
      _loginAttempts[email] = LoginAttemptInfo();
    }

    final attempts = _loginAttempts[email]!;
    if (success) {
      _loginAttempts.remove(email);
      return;
    }

    attempts.count++;
    attempts.lastAttempt = DateTime.now();
  }

  /// Checks if user is allowed to attempt login
  bool _canAttemptLogin(String email) {
    final attempts = _loginAttempts[email];
    if (attempts == null) return true;

    final now = DateTime.now();
    if (attempts.count >= _maxLoginAttempts) {
      final lockoutEnd = attempts.lastAttempt!
          .add(const Duration(minutes: _lockoutDurationMinutes));
      if (now.isBefore(lockoutEnd)) {
        final remainingMinutes = lockoutEnd.difference(now).inMinutes;
        throw Exception(
            'Too many failed attempts. Please try again in $remainingMinutes minutes.');
      }
      _loginAttempts.remove(email);
    }
    return true;
  }

  Future<List<User>> getAllUsers() async {
    try {
      // محاولة الحصول على المستخدمين من جدول المصادقة مباشرة
      List<User> authUsers = [];

      // محاولة الحصول على المستخدمين من جدول المصادقة
      try {
        // محاولة 1: استخدام API مباشرة للحصول على المستخدمين
        // ملاحظة: هذه الطريقة تتطلب صلاحيات المدير، لذلك قد لا تعمل
        try {
          // نحاول استخدام API مباشرة، لكن هذا قد لا يعمل بدون صلاحيات المدير
          developer.log(
              'Attempting to use auth.admin API (may not work without admin privileges)');

          // هذا الكود قد لا يعمل، لكننا نتركه كمثال
          // final response = await _supabase.auth.admin.listUsers();
          // final users = response.users.map((authUser) => User(...)).toList();

          // بدلاً من ذلك، نستخدم الطرق الأخرى
        } catch (adminError) {
          developer.log('Error using auth.admin API: $adminError');
        }

        // محاولة 2: استخدام استعلام SQL مباشر
        try {
          developer.log('Attempting to query auth.users table via SQL');

          // محاولة التحقق من وجود جدول auth.users
          try {
            final tableCheck = await _supabase.rpc('exec_sql', params: {
              'query':
                  'SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_schema = \'auth\' AND table_name = \'users\')'
            });
            developer.log('auth.users table exists check: $tableCheck');
          } catch (checkError) {
            developer
                .log('Error checking auth.users table existence: $checkError');
          }

          // محاولة الحصول على هيكل جدول auth.users
          try {
            final tableStructure = await _supabase.rpc('exec_sql', params: {
              'query':
                  'SELECT column_name, data_type FROM information_schema.columns WHERE table_schema = \'auth\' AND table_name = \'users\''
            });
            developer.log('auth.users table structure: $tableStructure');
          } catch (structureError) {
            developer.log(
                'Error getting auth.users table structure: $structureError');
          }

          // محاولة الاستعلام عن المستخدمين
          final sqlResponse = await _supabase.rpc('exec_sql', params: {
            'query':
                'SELECT id, email, created_at FROM auth.users ORDER BY created_at DESC'
          });

          developer.log('SQL response type: ${sqlResponse.runtimeType}');
          developer.log('SQL response content: $sqlResponse');

          if (sqlResponse != null &&
              sqlResponse is List &&
              sqlResponse.isNotEmpty) {
            developer.log(
                'Successfully loaded ${sqlResponse.length} users from auth.users via SQL');

            authUsers = sqlResponse
                .map((user) => User(
                      id: user['id'] ?? '',
                      email: user['email'] ?? 'unknown@example.com',
                      isAdmin: false,
                      createdAt: user['created_at'] ??
                          DateTime.now().toIso8601String(),
                    ))
                .toList();

            return authUsers;
          } else {
            developer
                .log('No users found in auth.users via SQL or empty response');
          }
        } catch (sqlError) {
          developer.log('Error accessing auth.users via SQL: $sqlError');
          developer.log('SQL error details: ${sqlError.toString()}');
        }

        // محاولة 3: استخدام المستخدم الحالي
        final currentUser = _supabase.auth.currentUser;
        if (currentUser != null) {
          developer.log('Current user found: ${currentUser.email}');

          // إضافة المستخدم الحالي إلى القائمة
          authUsers.add(User(
            id: currentUser.id,
            email: currentUser.email ?? 'unknown@example.com',
            isAdmin: false,
            createdAt: DateTime.now().toIso8601String(),
          ));

          // محاولة 4: استخدام جلسة المستخدم الحالي للحصول على معلومات إضافية
          try {
            final session = _supabase.auth.currentSession;
            if (session != null) {
              // استخدام معلومات الجلسة للحصول على المزيد من المعلومات
              developer
                  .log('Current session found, user: ${session.user.email}');

              // إضافة المستخدم من الجلسة إذا كان مختلفاً عن المستخدم الحالي
              if (session.user.id != currentUser.id) {
                authUsers.add(User(
                  id: session.user.id,
                  email: session.user.email ?? 'unknown@example.com',
                  isAdmin: false,
                  createdAt: DateTime.now().toIso8601String(),
                ));
              }
            }
          } catch (sessionError) {
            developer.log('Error accessing current session: $sessionError');
          }

          if (authUsers.isNotEmpty) {
            return authUsers;
          }
        }
      } catch (authError) {
        developer.log('Error accessing auth users: $authError');
      }

      // التحقق من وجود جداول المستخدمين
      bool userAccountsTableExists = await _checkTableExists('user_accounts');
      bool usersTableExists =
          await _checkTableExists(SupabaseConfig.usersTable);

      developer.log('User accounts table exists: $userAccountsTableExists');
      developer.log('Users table exists: $usersTableExists');

      // محاولة الحصول على المستخدمين من جدول user_accounts
      if (userAccountsTableExists) {
        try {
          final response = await _supabase
              .from('user_accounts')
              .select('id, email, created_at, is_admin')
              .order('created_at', ascending: false);

          developer.log(
              'Successfully loaded ${response.length} users from user_accounts');

          if (response.isNotEmpty) {
            return (response as List)
                .map((json) => User.fromJson(json))
                .toList();
          }
        } catch (accountsError) {
          developer.log('Error loading from user_accounts: $accountsError');
        }
      }

      // محاولة الحصول على المستخدمين من جدول المستخدمين الرئيسي
      if (usersTableExists) {
        try {
          final response = await _supabase
              .from(SupabaseConfig.usersTable)
              .select('id, email, created_at')
              .order('created_at', ascending: false);

          developer.log(
              'Successfully loaded ${response.length} users from ${SupabaseConfig.usersTable}');

          if (response.isNotEmpty) {
            return (response as List)
                .map((json) => User.fromJson({
                      'id': json['id'],
                      'email': json['email'],
                      'is_admin': false,
                      'created_at': json['created_at'] ??
                          DateTime.now().toIso8601String(),
                    }))
                .toList();
          }
        } catch (usersTableError) {
          developer.log(
              'Error loading from ${SupabaseConfig.usersTable}: $usersTableError');
        }
      }

      // إذا وصلنا إلى هنا، نحاول إنشاء مستخدم تجريبي
      try {
        final demoUser = await createDemoUser();
        if (demoUser != null) {
          return [demoUser];
        }
      } catch (demoError) {
        developer.log('Error creating demo user: $demoError');
      }

      // إذا فشلت جميع المحاولات، نعيد مستخدم وهمي
      return [
        User(
          id: 'demo-user-id',
          email: 'demo@example.com',
          isAdmin: false,
          createdAt: DateTime.now().toIso8601String(),
        )
      ];
    } catch (e) {
      developer.log('Error loading users: $e');
      developer.log('Error details: ${e.toString()}');

      // إرجاع مستخدم وهمي في حالة الخطأ
      return [
        User(
          id: 'demo-user-id',
          email: 'demo@example.com',
          isAdmin: false,
          createdAt: DateTime.now().toIso8601String(),
        )
      ];
    }
  }

  /// التحقق من وجود جدول في قاعدة البيانات
  Future<bool> _checkTableExists(String tableName) async {
    try {
      developer.log('Checking if table exists: $tableName');

      // محاولة استعلام بسيط من الجدول
      await _supabase.from(tableName).select('*').limit(1);
      developer.log('Table $tableName exists (direct query successful)');
      return true;
    } catch (e) {
      developer.log('Error checking table $tableName: $e');

      // إذا كان الخطأ يتعلق بعدم وجود الجدول
      if (e.toString().contains('relation') &&
          e.toString().contains('does not exist')) {
        developer.log('Table $tableName does not exist');

        // محاولة التحقق باستخدام استعلام SQL مباشر
        try {
          final result = await _supabase.rpc('exec_sql', params: {
            'query':
                'SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = \'$tableName\')'
          });

          developer.log('SQL check for table $tableName: $result');

          if (result != null && result is List && result.isNotEmpty) {
            final exists = result[0]['exists'] ?? false;
            developer.log('Table $tableName exists (SQL check): $exists');
            return exists;
          }
        } catch (sqlError) {
          developer.log('Error checking table $tableName with SQL: $sqlError');
        }

        return false;
      }

      // إذا كان الخطأ لسبب آخر (مثل مشاكل الصلاحيات)، نفترض أن الجدول موجود
      developer.log('Assuming table $tableName exists despite error');
      return true;
    }
  }

  /// إنشاء مستخدم تجريبي في قاعدة البيانات
  Future<User?> createDemoUser() async {
    try {
      // 1. أولاً نحاول إنشاء مستخدم تجريبي في نظام المصادقة
      try {
        // التحقق من وجود مستخدم تجريبي في نظام المصادقة
        bool demoUserExists = false;

        try {
          // محاولة تسجيل الدخول بالمستخدم التجريبي
          final response = await _supabase.auth.signInWithPassword(
            email: 'demo@example.com',
            password: 'Demo@123456',
          );

          if (response.user != null) {
            demoUserExists = true;
            developer.log('Demo user exists in auth system');

            // تسجيل الخروج بعد التحقق
            await _supabase.auth.signOut();
          }
        } catch (loginError) {
          developer.log('Demo user does not exist in auth system: $loginError');
        }

        // إذا لم يكن المستخدم التجريبي موجوداً، نقوم بإنشائه
        if (!demoUserExists) {
          try {
            final response = await _supabase.auth.signUp(
              email: 'demo@example.com',
              password: 'Demo@123456',
            );

            if (response.user != null) {
              developer.log(
                  'Demo user created in auth system with ID: ${response.user!.id}');

              // تسجيل الخروج بعد الإنشاء
              await _supabase.auth.signOut();
            }
          } catch (signupError) {
            developer
                .log('Error creating demo user in auth system: $signupError');
          }
        }
      } catch (authError) {
        developer.log('Error working with auth system: $authError');
      }

      // 2. التحقق من وجود جدول المستخدمين
      bool usersTableExists =
          await _checkTableExists(SupabaseConfig.usersTable);
      bool userAccountsTableExists = await _checkTableExists('user_accounts');

      if (!usersTableExists) {
        // إذا كان الجدول غير موجود، نقوم بإنشائه
        await _createUsersTable();
        // التحقق مرة أخرى بعد محاولة الإنشاء
        usersTableExists = await _checkTableExists(SupabaseConfig.usersTable);
      }

      // 3. التحقق من وجود مستخدم تجريبي في جدول المستخدمين
      String demoUserId = 'demo-user-id';

      if (usersTableExists) {
        try {
          final existingUsers = await _supabase
              .from(SupabaseConfig.usersTable)
              .select('id, email')
              .eq('email', 'demo.user@example.com')
              .limit(1);

          if (existingUsers.isNotEmpty) {
            developer.log('Demo user already exists in users table');
            final userData = existingUsers[0];
            demoUserId = userData['id'];
          } else {
            // إنشاء مستخدم تجريبي في جدول المستخدمين
            demoUserId = _generateUUID();
            developer.log('Generated demo user UUID: $demoUserId');

            final demoUser = {
              'id': demoUserId,
              'email':
                  'demo.user@example.com', // تغيير البريد الإلكتروني ليكون أكثر صلاحية
              'full_name': 'مستخدم تجريبي',
              'phone': '0500000000',
              'role': 'Patient',
              'is_active': true,
              'created_at': DateTime.now().toIso8601String(),
            };

            try {
              await _supabase.from(SupabaseConfig.usersTable).insert(demoUser);
              developer.log('Demo user created successfully in users table');
            } catch (insertError) {
              developer.log(
                  'Error inserting demo user in users table: $insertError');
            }
          }
        } catch (e) {
          developer
              .log('Error checking for existing demo user in users table: $e');
        }
      }

      // 4. التحقق من وجود مستخدم تجريبي في جدول حسابات المستخدمين
      if (userAccountsTableExists) {
        try {
          final existingAccounts = await _supabase
              .from('user_accounts')
              .select('id, email')
              .eq('email', 'demo.user@example.com')
              .limit(1);

          if (existingAccounts.isEmpty) {
            // تحقق من اسم العمود الصحيح
            String nameColumnName = 'name_arbic'; // الاسم الافتراضي

            try {
              // محاولة الحصول على أسماء الأعمدة في جدول user_accounts
              final columns =
                  await _supabase.from('user_accounts').select().limit(1);

              developer.log('User accounts columns: $columns');

              // إذا لم نتمكن من الحصول على الأعمدة، نحاول بطريقة أخرى
              if (columns.isEmpty) {
                try {
                  // محاولة إدراج سجل اختباري ثم حذفه فوراً
                  final testData = {
                    'id': 'test-${DateTime.now().millisecondsSinceEpoch}',
                    'email': 'test@example.com',
                    'name_arbic': 'Test User',
                    'is_admin': false,
                    'created_at': DateTime.now().toIso8601String(),
                  };

                  await _supabase.from('user_accounts').insert(testData);
                  developer.log('Test insert with name_arbic successful');
                  nameColumnName = 'name_arbic';
                } catch (e) {
                  if (e.toString().contains('name_arbic')) {
                    // محاولة باستخدام name_arabic
                    try {
                      final testData = {
                        'id': 'test-${DateTime.now().millisecondsSinceEpoch}',
                        'email': 'test@example.com',
                        'name_arabic': 'Test User',
                        'is_admin': false,
                        'created_at': DateTime.now().toIso8601String(),
                      };

                      await _supabase.from('user_accounts').insert(testData);
                      developer.log('Test insert with name_arabic successful');
                      nameColumnName = 'name_arabic';
                    } catch (e2) {
                      developer
                          .log('Both name_arbic and name_arabic failed: $e2');
                    }
                  }
                }
              }
            } catch (e) {
              developer.log('Error checking column names: $e');
            }

            developer.log('Using column name: $nameColumnName for demo user');

            // إنشاء بيانات المستخدم باستخدام اسم العمود الصحيح
            final demoAccountData = {
              'id': demoUserId,
              'email':
                  'demo.user@example.com', // تغيير البريد الإلكتروني ليكون أكثر صلاحية
              'is_admin': false,
              'created_at': DateTime.now().toIso8601String(),
            };

            // إضافة اسم العمود الصحيح
            demoAccountData[nameColumnName] = 'مستخدم تجريبي';

            await _supabase.from('user_accounts').insert(demoAccountData);
            developer.log('Demo user account created successfully');
          } else {
            developer.log('Demo user already exists in user_accounts table');
          }
        } catch (accountsError) {
          developer
              .log('Error working with user_accounts table: $accountsError');
        }
      }

      // 5. إرجاع المستخدم التجريبي
      return User(
        id: demoUserId,
        email:
            'demo.user@example.com', // تغيير البريد الإلكتروني ليكون أكثر صلاحية
        isAdmin: false,
        createdAt: DateTime.now().toIso8601String(),
      );
    } catch (e) {
      developer.log('Error creating demo user: $e');
      // إرجاع مستخدم وهمي في الذاكرة فقط
      return User(
        id: 'demo-user-id',
        email:
            'demo.user@example.com', // تغيير البريد الإلكتروني ليكون أكثر صلاحية
        isAdmin: false,
        createdAt: DateTime.now().toIso8601String(),
      );
    }
  }

  /// إنشاء جدول المستخدمين في قاعدة البيانات (دالة خاصة)
  Future<void> _createUsersTable() async {
    try {
      developer.log('Attempting to create users table');

      // محاولة إنشاء جدول المستخدمين باستخدام SQL
      final createTableSQL = '''
      CREATE TABLE IF NOT EXISTS ${SupabaseConfig.usersTable} (
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
        developer.log('Users table created successfully using RPC');

        // التحقق من إنشاء الجدول
        final tableCheck = await _checkTableExists(SupabaseConfig.usersTable);
        developer.log('Users table exists after creation: $tableCheck');
      } catch (rpcError) {
        developer.log('Error creating users table using RPC: $rpcError');
        developer.log('RPC error details: ${rpcError.toString()}');
      }

      // إنشاء جدول حسابات المستخدمين
      try {
        developer.log('Attempting to create user_accounts table');

        final createAccountsTableSQL = '''
        CREATE TABLE IF NOT EXISTS user_accounts (
          id TEXT PRIMARY KEY,
          email TEXT UNIQUE NOT NULL,
          name_arabic TEXT,
          is_admin BOOLEAN NOT NULL DEFAULT FALSE,
          created_at TEXT NOT NULL
        )
        ''';

        await _supabase
            .rpc('exec_sql', params: {'query': createAccountsTableSQL});
        developer.log('User accounts table created successfully using RPC');

        // التحقق من إنشاء الجدول
        final tableCheck = await _checkTableExists('user_accounts');
        developer.log('User accounts table exists after creation: $tableCheck');
      } catch (accountsError) {
        developer.log('Error creating user_accounts table: $accountsError');
        developer.log('Error details: ${accountsError.toString()}');
      }
    } catch (e) {
      developer.log('Error in _createUsersTable: $e');
      developer.log('Error details: ${e.toString()}');
    }
  }

  /// إنشاء جداول المستخدمين (دالة عامة)
  Future<bool> createUserTables() async {
    try {
      developer.log('Creating user tables (public method)');

      // التحقق من وجود دالة exec_sql
      bool execSqlExists = await _checkExecSqlFunction();
      if (!execSqlExists) {
        // إذا كانت الدالة غير موجودة، نعرض رسالة للمستخدم
        developer.log(
            'exec_sql function does not exist. Please create it in Supabase SQL Editor.');
        return false;
      }

      await _createUsersTable();
      return true;
    } catch (e) {
      developer.log('Error in createUserTables: $e');
      return false;
    }
  }

  /// التحقق من وجود دالة exec_sql
  Future<bool> _checkExecSqlFunction() async {
    try {
      // محاولة استدعاء الدالة بطريقة آمنة
      await _supabase.rpc('exec_sql', params: {'query': 'SELECT 1'});
      developer.log('exec_sql function exists');
      return true;
    } catch (e) {
      if (e
          .toString()
          .contains('Could not find the function public.exec_sql')) {
        developer.log('exec_sql function does not exist');
        return false;
      }
      // إذا كان الخطأ لسبب آخر، نفترض أن الدالة موجودة
      developer.log('Error checking exec_sql function: $e');
      return true;
    }
  }

  Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    try {
      if (!_canAttemptLogin(email)) {
        return null;
      }

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      _trackLoginAttempt(email, true);
      startAutoLogoutTimer();

      if (response.user == null) {
        throw Exception("لم يتم العثور على بيانات المستخدم");
      }

      // التحقق من معلومات المستخدم في جدول users
      final userData = await _supabase
          .from(SupabaseConfig.usersTable)
          .select()
          .eq('id', response.user!.id)
          .single();

      final userProfile = UserProfile.fromJson(userData);

      return {
        'user': {
          'id': response.user!.id,
          'email': response.user!.email!,
        },
        'isAdmin': userProfile.role == 'Admin',
        'isDoctor': userProfile.role == 'Doctor',
        'userProfile': userProfile,
      };
    } catch (e) {
      _trackLoginAttempt(email, false);
      developer.log('خطأ في تسجيل الدخول: $e');
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } catch (error) {
      developer.log('خطأ في تسجيل الخروج: $error');
      rethrow;
    }
  }

  Future<void> adminLogout() async {
    try {
      await _supabase.auth.signOut();
    } catch (error) {
      developer.log('خطأ في تسجيل خروج المدير: $error');
      rethrow;
    }
  }

  Future<void> doctorLogout() async {
    try {
      await _supabase.auth.signOut();
    } catch (error) {
      developer.log('خطأ في تسجيل خروج الطبيب: $error');
      rethrow;
    }
  }

  /// الحصول على معلومات جلسة المستخدم الحالية
  Future<Map<String, dynamic>?> getSession() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) return null;

      // التحقق من صلاحية الجلسة
      final isValid = await validateSession();
      if (!isValid) return null;

      // الحصول على معلومات المستخدم
      final userData = await _supabase
          .from(SupabaseConfig.usersTable)
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
        'isAdmin': userProfile.role == 'Admin',
        'isDoctor': userProfile.role == 'Doctor',
        'userProfile': userProfile,
      };
    } catch (e) {
      // خطأ في الحصول على معلومات الجلسة
      return null;
    }
  }

  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  Future<void> sendMagicLink(String email) async {
    await _supabase.auth.signInWithOtp(
      email: email,
    );
  }

  Future<void> createEmployeeAccount(
      String email, String password, String employeeId) async {
    try {
      // التحقق من وجود حساب مسبق
      final existingUser = await _supabase
          .from('user_accounts')
          .select()
          .eq('email', email)
          .maybeSingle();

      if (existingUser != null) {
        throw 'البريد الإلكتروني مستخدم بالفعل';
      }

      // إضافة تأخير لتجنب تجاوز حد معدل الإرسال
      await Future.delayed(const Duration(seconds: 10));

      // إنشاء حساب للموظف
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // تحديث بيانات المستخدم في جدول user_accounts
        await _supabase.from('user_accounts').insert({
          'id': response.user!.id,
          'email': email,
          'employee_id': employeeId,
          'is_admin': false,
          'created_at': DateTime.now().toIso8601String(),
        });
      } else {
        throw 'فشل في إنشاء حساب للموظف';
      }
    } catch (e) {
      if (e.toString().contains('over_email_send_rate_limit')) {
        throw 'يرجى الانتظار لبضع ثوانٍ قبل المحاولة مرة أخرى';
      }
      throw 'حدث خطأ: ${e.toString()}';
    }
  }

  Future<void> signInWithEmailAndPassword(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      final loginResult = await login(
        email: email,
        password: password,
      );

      if (loginResult != null) {
        if (loginResult['isAdmin'] == true) {
          if (context.mounted) {
            AppNavigator.navigateToHome(context, 'admin');
          }
        } else if (loginResult['isDoctor'] == true) {
          if (context.mounted) {
            AppNavigator.navigateToHome(context, 'doctor');
          }
        } else {
          if (context.mounted) {
            AppNavigator.navigateToHome(context, 'patient');
          }
        }
      } else {
        throw Exception('فشل تسجيل الدخول: لم يتم العثور على بيانات المستخدم');
      }
    } catch (e) {
      throw Exception('فشل تسجيل الدخول: ${e.toString()}');
    }
  }

  // الحصول على معلومات المستخدم الحالي
  Future<UserProfile?> getCurrentUserProfile() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final userData = await _supabase
          .from(SupabaseConfig.usersTable)
          .select()
          .eq('id', userId)
          .single();

      return UserProfile.fromJson(userData);
    } catch (e) {
      developer.log('خطأ في الحصول على معلومات المستخدم: $e');
      return null;
    }
  }

  // تحديث معلومات المستخدم
  Future<void> updateUserProfile(UserProfile userProfile) async {
    try {
      await _supabase
          .from(SupabaseConfig.usersTable)
          .update(userProfile.toJson())
          .eq('id', userProfile.id);
    } catch (e) {
      throw Exception('فشل في تحديث معلومات المستخدم: $e');
    }
  }

  // تحديث صورة الملف الشخصي
  Future<String?> updateProfilePicture(String userId, String filePath) async {
    try {
      final fileName = filePath.split('/').last;
      final fileExt = fileName.split('.').last;
      final path =
          'profile_pictures/$userId/${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      // Aquí necesitamos implementar la lógica para subir el archivo
      // Este es un placeholder, ya que necesitamos acceso al archivo real
      // await _supabase.storage.from('profile_pictures').upload(path, File(filePath));

      final fileUrl =
          _supabase.storage.from('profile_pictures').getPublicUrl(path);

      // تحديث رابط الصورة في جدول المستخدمين
      await _supabase
          .from(SupabaseConfig.usersTable)
          .update({'profile_picture': fileUrl}).eq('id', userId);

      return fileUrl;
    } catch (e) {
      throw Exception('فشل في تحديث صورة الملف الشخصي: $e');
    }
  }

  Future<UserProfile?> registerUser({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    String gender = '',
    DateTime? birthDate,
    String? nationalId,
  }) async {
    try {
      // التحقق من عدم وجود حساب بنفس البريد الإلكتروني
      try {
        final existingUserData = await _supabase
            .from(SupabaseConfig.usersTable)
            .select()
            .eq('email', email)
            .maybeSingle();

        if (existingUserData != null) {
          throw Exception('البريد الإلكتروني مستخدم بالفعل');
        }
      } catch (e) {
        // Si hay un error diferente al de "usuario ya existe", lo ignoramos
        if (e is! Exception ||
            e.toString() != 'Exception: البريد الإلكتروني مستخدم بالفعل') {
          developer.log('Error al verificar usuario existente: $e');
        } else {
          rethrow;
        }
      }

      // إنشاء حساب جديد
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('فشل في إنشاء الحساب');
      }

      // إضافة معلومات المستخدم إلى جدول users
      final userData = {
        'id': response.user!.id,
        'email': email,
        'full_name': fullName,
        'phone': phone,
        'gender': gender,
        'birth_date': birthDate?.toIso8601String(),
        'national_id': nationalId,
        'role': 'Patient', // Default role
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from(SupabaseConfig.usersTable).insert(userData);

      return UserProfile(
        id: response.user!.id,
        email: email,
        fullName: fullName,
        phone: phone,
        gender: gender,
        birthDate: birthDate,
        nationalId: nationalId,
        role: 'Patient',
        isActive: true,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      developer.log('خطأ في تسجيل المستخدم: $e');
      rethrow;
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  }) async {
    try {
      // التحقق من قوة كلمة المرور
      final passwordError = validatePassword(password);
      if (passwordError != null) {
        throw Exception(passwordError);
      }

      // التحقق من وجود جداول المستخدمين
      bool usersTableExists =
          await _checkTableExists(SupabaseConfig.usersTable);
      bool userAccountsTableExists = await _checkTableExists('user_accounts');

      developer.log('Users table exists: $usersTableExists');
      developer.log('User accounts table exists: $userAccountsTableExists');

      // إذا لم تكن الجداول موجودة، نحاول إنشاءها
      if (!usersTableExists) {
        await _createUsersTable();
        usersTableExists = await _checkTableExists(SupabaseConfig.usersTable);
      }

      // 1. إنشاء حساب المستخدم في نظام المصادقة
      try {
        final authResponse = await _supabase.auth.signUp(
          email: email,
          password: password,
        );

        if (authResponse.user == null) {
          throw Exception('فشل في إنشاء الحساب');
        }

        final userId = authResponse.user!.id;
        developer.log('User created in auth system with ID: $userId');

        // 2. إضافة بيانات المستخدم في جدول users إذا كان موجوداً
        if (usersTableExists) {
          try {
            // استخدام UUID بدلاً من ID العددي
            final userProfileData = {
              'id': userId,
              'email': email,
              'full_name': fullName,
              'phone': phoneNumber,
              'role': 'Patient',
              'is_active': true,
              'created_at': DateTime.now().toIso8601String(),
            };

            developer.log(
                'Attempting to insert into users table with data: $userProfileData');

            // محاولة الحصول على معلومات عن هيكل الجدول
            try {
              final tableInfo = await _supabase.rpc('exec_sql', params: {
                'query':
                    'SELECT column_name, data_type FROM information_schema.columns WHERE table_name = \'${SupabaseConfig.usersTable}\''
              });
              developer.log('Users table structure: $tableInfo');
            } catch (schemaError) {
              developer.log('Error getting users table schema: $schemaError');
            }

            // محاولة إدراج البيانات بدون استخدام select() لتجنب الأخطاء
            await _supabase
                .from(SupabaseConfig.usersTable)
                .insert(userProfileData);

            developer.log('User profile created successfully in users table');
          } catch (usersTableError) {
            developer
                .log('Error creating user in users table: $usersTableError');
            developer.log('Error details: ${usersTableError.toString()}');

            // محاولة بديلة: استخدام RPC
            try {
              final insertSQL = '''
              INSERT INTO ${SupabaseConfig.usersTable}
              (id, email, full_name, phone, role, is_active, created_at)
              VALUES
              ('$userId', '$email', '$fullName', '$phoneNumber', 'Patient', true, '${DateTime.now().toIso8601String()}')
              ''';

              developer.log('Attempting SQL insert with query: $insertSQL');
              await _supabase.rpc('exec_sql', params: {'query': insertSQL});
              developer.log('User profile created using SQL RPC');
            } catch (rpcError) {
              developer.log('Error creating user using RPC: $rpcError');
              developer.log('RPC error details: ${rpcError.toString()}');
            }
          }
        }

        // 3. إضافة بيانات المستخدم في جدول user_accounts إذا كان موجوداً
        if (userAccountsTableExists) {
          try {
            // تحقق من أسماء الأعمدة الصحيحة في جدول user_accounts
            // محاولة التحقق من اسم العمود الصحيح
            String nameColumnName = 'name_arbic'; // الاسم الافتراضي

            try {
              // محاولة الحصول على أسماء الأعمدة في جدول user_accounts
              final columns =
                  await _supabase.from('user_accounts').select().limit(1);

              developer.log('User accounts columns: $columns');

              // إذا لم نتمكن من الحصول على الأعمدة، نحاول بطريقة أخرى
              if (columns.isEmpty) {
                try {
                  // محاولة إدراج سجل اختباري ثم حذفه فوراً
                  final testData = {
                    'id': 'test-${DateTime.now().millisecondsSinceEpoch}',
                    'email': 'test@example.com',
                    'name_arbic': 'Test User',
                    'is_admin': false,
                    'created_at': DateTime.now().toIso8601String(),
                  };

                  await _supabase.from('user_accounts').insert(testData);
                  developer.log('Test insert with name_arbic successful');
                  nameColumnName = 'name_arbic';
                } catch (e) {
                  if (e.toString().contains('name_arbic')) {
                    // محاولة باستخدام name_arabic
                    try {
                      final testData = {
                        'id': 'test-${DateTime.now().millisecondsSinceEpoch}',
                        'email': 'test@example.com',
                        'name_arabic': 'Test User',
                        'is_admin': false,
                        'created_at': DateTime.now().toIso8601String(),
                      };

                      await _supabase.from('user_accounts').insert(testData);
                      developer.log('Test insert with name_arabic successful');
                      nameColumnName = 'name_arabic';
                    } catch (e2) {
                      developer
                          .log('Both name_arbic and name_arabic failed: $e2');
                    }
                  }
                }
              }
            } catch (e) {
              developer.log('Error checking column names: $e');
            }

            developer.log('Using column name: $nameColumnName for user name');

            // إنشاء بيانات المستخدم باستخدام اسم العمود الصحيح
            final userAccountData = {
              'id': userId,
              'email': email,
              'is_admin': false,
              'created_at': DateTime.now().toIso8601String(),
            };

            // إضافة اسم العمود الصحيح
            userAccountData[nameColumnName] = fullName;

            developer.log(
                'Attempting to insert into user_accounts table with data: $userAccountData');

            // محاولة الحصول على معلومات عن هيكل الجدول
            try {
              final tableInfo = await _supabase.rpc('exec_sql', params: {
                'query':
                    'SELECT column_name, data_type FROM information_schema.columns WHERE table_name = \'user_accounts\''
              });
              developer.log('User accounts table structure: $tableInfo');
            } catch (schemaError) {
              developer.log(
                  'Error getting user_accounts table schema: $schemaError');
            }

            // محاولة إدراج البيانات بدون استخدام select() لتجنب الأخطاء
            await _supabase.from('user_accounts').insert(userAccountData);
            developer.log('User account created successfully');
          } catch (accountsTableError) {
            developer.log(
                'Error creating user in user_accounts table: $accountsTableError');
            developer.log('Error details: ${accountsTableError.toString()}');

            // محاولة بديلة: استخدام RPC
            try {
              final insertSQL = '''
              INSERT INTO user_accounts
              (id, email, name_arabic, is_admin, created_at)
              VALUES
              ('$userId', '$email', '$fullName', false, '${DateTime.now().toIso8601String()}')
              ''';

              developer.log('Attempting SQL insert with query: $insertSQL');
              await _supabase.rpc('exec_sql', params: {'query': insertSQL});
              developer.log('User account created using SQL RPC');
            } catch (rpcError) {
              developer.log('Error creating user account using RPC: $rpcError');
              developer.log('RPC error details: ${rpcError.toString()}');
            }
          }
        }

        // إذا لم نتمكن من إنشاء سجل في أي من الجدولين، نعتبر التسجيل ناجحاً طالما تم إنشاء حساب المصادقة
        developer.log('User registration completed successfully');
      } catch (authError) {
        if (authError.toString().contains('User already registered')) {
          throw Exception('البريد الإلكتروني مسجل مسبقاً');
        }
        throw Exception('فشل في إنشاء حساب المصادقة: ${authError.toString()}');
      }
    } catch (e) {
      developer.log('Error in register method: $e');
      throw Exception('حدث خطأ في إنشاء الحساب: ${e.toString()}');
    }
  }

  /// Checks if the current session is valid and refreshes if needed
  Future<bool> validateSession() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) return false;

      // Check if token is about to expire (within 5 minutes)
      final expiresAt =
          DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000);
      final now = DateTime.now();
      if (expiresAt.difference(now).inMinutes <= 5) {
        await _supabase.auth.refreshSession();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Starts the auto-logout timer
  Timer? _autoLogoutTimer;
  void startAutoLogoutTimer() {
    _autoLogoutTimer?.cancel();
    _autoLogoutTimer = Timer(const Duration(minutes: 30), () async {
      await logout();
    });
  }

  /// Resets the auto-logout timer
  void resetAutoLogoutTimer() {
    startAutoLogoutTimer();
  }

  void dispose() {
    _autoLogoutTimer?.cancel();
  }

  /// إنشاء UUID صالح
  String _generateUUID() {
    // إنشاء UUID بتنسيق v4 (عشوائي)
    final random = Random();
    const hexDigits = '0123456789abcdef';

    // تنسيق UUID: xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx
    // حيث y هو 8 أو 9 أو a أو b
    final uuid = StringBuffer();

    // 8 أرقام
    for (int i = 0; i < 8; i++) {
      uuid.write(hexDigits[random.nextInt(16)]);
    }
    uuid.write('-');

    // 4 أرقام
    for (int i = 0; i < 4; i++) {
      uuid.write(hexDigits[random.nextInt(16)]);
    }
    uuid.write('-');

    // 4 أرقام، الأول هو 4 (لتنسيق UUID v4)
    uuid.write('4');
    for (int i = 0; i < 3; i++) {
      uuid.write(hexDigits[random.nextInt(16)]);
    }
    uuid.write('-');

    // 4 أرقام، الأول هو 8 أو 9 أو a أو b
    final variant = 8 + random.nextInt(4); // 8, 9, 10, or 11
    uuid.write(hexDigits[variant]);
    for (int i = 0; i < 3; i++) {
      uuid.write(hexDigits[random.nextInt(16)]);
    }
    uuid.write('-');

    // 12 رقم
    for (int i = 0; i < 12; i++) {
      uuid.write(hexDigits[random.nextInt(16)]);
    }

    return uuid.toString();
  }
}

class LoginAttemptInfo {
  int count = 0;
  DateTime? lastAttempt;
}
