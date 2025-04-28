-- Enable RLS on hospitals table
ALTER TABLE public.hospitals ENABLE ROW LEVEL SECURITY;

-- Policy for authenticated users to view active hospitals
CREATE POLICY "View active hospitals"
ON public.hospitals
FOR SELECT
TO authenticated
USING (is_active = true);

-- Policy for admin to manage hospitals
CREATE POLICY "Admin manage hospitals"
ON public.hospitals
FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM auth.users
    WHERE auth.users.id = auth.uid()
    AND auth.users.role = 'admin'
  )
);

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT SELECT ON public.hospitals TO authenticated;

-- Create a regions view for easy access
CREATE OR REPLACE VIEW public.regions AS
SELECT DISTINCT region
FROM public.hospitals
WHERE is_active = true
ORDER BY region;

-- Create a cities view for easy access
CREATE OR REPLACE VIEW public.cities AS
SELECT DISTINCT city
FROM public.hospitals
WHERE is_active = true
ORDER BY city;

-- Grant access to authenticated users
GRANT SELECT ON public.regions TO authenticated;
GRANT SELECT ON public.cities TO authenticated; 