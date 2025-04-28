-- إنشاء جدول المستخدمين إذا لم يكن موجوداً
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT,
  phone TEXT,
  gender TEXT,
  birth_date TIMESTAMP WITH TIME ZONE,
  profile_picture TEXT,
  national_id TEXT,
  role TEXT NOT NULL DEFAULT 'Patient',
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE
);

-- إنشاء جدول الموظفين إذا لم يكن موجوداً
CREATE TABLE IF NOT EXISTS employees (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  employee_id TEXT UNIQUE,
  department TEXT,
  position TEXT,
  hire_date TIMESTAMP WITH TIME ZONE,
  salary NUMERIC,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE
);

-- إنشاء جدول user_accounts إذا لم يكن موجوداً
CREATE TABLE IF NOT EXISTS user_accounts (
  id UUID PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  employee_id TEXT,
  name_arbic TEXT,
  is_admin BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE
);

-- إنشاء الفهارس للبحث السريع
CREATE INDEX IF NOT EXISTS users_email_idx ON users(email);
CREATE INDEX IF NOT EXISTS employees_user_id_idx ON employees(user_id);
CREATE INDEX IF NOT EXISTS user_accounts_email_idx ON user_accounts(email);

-- إضافة سياسات الأمان (Row Level Security)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE employees ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_accounts ENABLE ROW LEVEL SECURITY;

-- سياسة للمستخدمين المصادقين لرؤية بياناتهم الخاصة
CREATE POLICY users_select_own ON users
  FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

-- سياسة للمديرين لرؤية جميع المستخدمين
CREATE POLICY users_select_all_admin ON users
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_accounts
      WHERE user_accounts.id = auth.uid()
      AND user_accounts.is_admin = TRUE
    )
  );

-- سياسة مماثلة للموظفين
CREATE POLICY employees_select_own ON employees
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY employees_select_all_admin ON employees
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_accounts
      WHERE user_accounts.id = auth.uid()
      AND user_accounts.is_admin = TRUE
    )
  );

-- سياسة لحسابات المستخدمين
CREATE POLICY user_accounts_select_own ON user_accounts
  FOR SELECT
  TO authenticated
  USING (id = auth.uid());

CREATE POLICY user_accounts_select_all_admin ON user_accounts
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_accounts
      WHERE user_accounts.id = auth.uid()
      AND user_accounts.is_admin = TRUE
    )
  );
