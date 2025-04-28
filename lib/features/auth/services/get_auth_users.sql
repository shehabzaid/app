-- دالة SQL لجلب المستخدمين من جدول المصادقة
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
