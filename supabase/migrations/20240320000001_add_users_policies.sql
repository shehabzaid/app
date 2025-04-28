-- Enable RLS on users table
ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;

-- Policy for users to view their own data
CREATE POLICY "Users can view own data" ON auth.users
FOR SELECT
TO authenticated
USING (auth.uid() = id);

-- Policy for admin to view all users
CREATE POLICY "Admin can view all users" ON auth.users
FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM auth.users
    WHERE auth.users.id = auth.uid()
    AND auth.users.role = 'admin'
  )
);

-- Grant necessary permissions to authenticated users
GRANT USAGE ON SCHEMA auth TO authenticated;
GRANT SELECT ON auth.users TO authenticated;

-- Create a secure wrapper table for user profiles
CREATE TABLE IF NOT EXISTS public.user_profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id),
  email text,
  role text,
  created_at timestamp with time zone,
  updated_at timestamp with time zone
);

-- Enable RLS on the user_profiles table
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

-- Create policies for user_profiles
CREATE POLICY "Users can view own profile" ON public.user_profiles
FOR SELECT
TO authenticated
USING (auth.uid() = id);

CREATE POLICY "Admin can manage all profiles" ON public.user_profiles
FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM auth.users
    WHERE auth.users.id = auth.uid()
    AND auth.users.role = 'admin'
  )
);

-- Function to sync user data
CREATE OR REPLACE FUNCTION public.sync_user_profile()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.user_profiles (id, email, role, created_at, updated_at)
  VALUES (
    NEW.id,
    NEW.email,
    NEW.role,
    NEW.created_at,
    NEW.updated_at
  )
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    role = EXCLUDED.role,
    updated_at = EXCLUDED.updated_at;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for syncing user data
DROP TRIGGER IF EXISTS sync_user_profile_trigger ON auth.users;
CREATE TRIGGER sync_user_profile_trigger
AFTER INSERT OR UPDATE ON auth.users
FOR EACH ROW
EXECUTE FUNCTION public.sync_user_profile();

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT SELECT ON public.user_profiles TO authenticated;

-- Sync existing users
INSERT INTO public.user_profiles (id, email, role, created_at, updated_at)
SELECT id, email, role, created_at, updated_at
FROM auth.users
ON CONFLICT (id) DO UPDATE SET
  email = EXCLUDED.email,
  role = EXCLUDED.role,
  updated_at = EXCLUDED.updated_at; 