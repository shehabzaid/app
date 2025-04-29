-- Create advertisements table
CREATE TABLE IF NOT EXISTS public.advertisements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  image_url TEXT NOT NULL,
  target_url TEXT,
  start_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  end_date TIMESTAMP WITH TIME ZONE,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Add comments to the table and columns
COMMENT ON TABLE public.advertisements IS 'Table for storing advertisements and promotional banners';
COMMENT ON COLUMN public.advertisements.id IS 'Unique identifier for the advertisement';
COMMENT ON COLUMN public.advertisements.title IS 'Title of the advertisement';
COMMENT ON COLUMN public.advertisements.description IS 'Optional description of the advertisement';
COMMENT ON COLUMN public.advertisements.image_url IS 'URL to the advertisement image';
COMMENT ON COLUMN public.advertisements.target_url IS 'Optional URL that the advertisement links to';
COMMENT ON COLUMN public.advertisements.start_date IS 'Date when the advertisement becomes active';
COMMENT ON COLUMN public.advertisements.end_date IS 'Optional date when the advertisement expires';
COMMENT ON COLUMN public.advertisements.is_active IS 'Whether the advertisement is currently active';
COMMENT ON COLUMN public.advertisements.created_at IS 'Timestamp when the advertisement was created';
COMMENT ON COLUMN public.advertisements.updated_at IS 'Timestamp when the advertisement was last updated';

-- Enable RLS on advertisements table
ALTER TABLE public.advertisements ENABLE ROW LEVEL SECURITY;

-- Policy for authenticated users to view active advertisements
CREATE POLICY "View active advertisements"
ON public.advertisements
FOR SELECT
TO authenticated
USING (is_active = true);

-- Policy for admin to manage advertisements
CREATE POLICY "Admin manage advertisements"
ON public.advertisements
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
GRANT SELECT ON public.advertisements TO authenticated;

-- Insert sample advertisements
INSERT INTO public.advertisements (title, description, image_url, start_date, is_active)
VALUES 
('خصم 20% على الفحوصات الطبية', 'خصم خاص لمستخدمي تطبيق صحتي بلس', 'https://via.placeholder.com/800x400.png?text=خصم+20%+على+الفحوصات+الطبية', NOW(), TRUE),
('افتتاح قسم جديد للعلاج الطبيعي', 'نرحب بكم في قسم العلاج الطبيعي الجديد', 'https://via.placeholder.com/800x400.png?text=افتتاح+قسم+جديد+للعلاج+الطبيعي', NOW(), TRUE),
('احجز موعدك الآن', 'احجز موعدك بسهولة من خلال تطبيق صحتي بلس', 'https://via.placeholder.com/800x400.png?text=احجز+موعدك+الآن', NOW(), TRUE);
