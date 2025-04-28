-- إنشاء جدول المستخدمين
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
);

-- إنشاء جدول حسابات المستخدمين
CREATE TABLE IF NOT EXISTS user_accounts (
  id TEXT PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  name_arbic TEXT,
  is_admin BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TEXT NOT NULL
);

-- إنشاء دالة لجلب المستخدمين من جدول المصادقة
CREATE OR REPLACE FUNCTION get_auth_users()
RETURNS SETOF json AS $$
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
$$ LANGUAGE plpgsql SECURITY DEFINER;
