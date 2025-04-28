-- Add new columns to hospitals table
ALTER TABLE hospitals
ADD COLUMN IF NOT EXISTS name_english text,
ADD COLUMN IF NOT EXISTS address_english text,
ADD COLUMN IF NOT EXISTS phone text,
ADD COLUMN IF NOT EXISTS email text,
ADD COLUMN IF NOT EXISTS location_lat double precision,
ADD COLUMN IF NOT EXISTS location_long double precision,
ADD COLUMN IF NOT EXISTS type text NOT NULL DEFAULT 'حكومي',
ADD COLUMN IF NOT EXISTS image_url text,
ADD COLUMN IF NOT EXISTS departments text[] NOT NULL DEFAULT '{}',
ADD COLUMN IF NOT EXISTS is_active boolean NOT NULL DEFAULT true;

-- Add comments to the new columns
COMMENT ON COLUMN hospitals.name_english IS 'Hospital name in English';
COMMENT ON COLUMN hospitals.address_english IS 'Hospital address in English';
COMMENT ON COLUMN hospitals.phone IS 'Hospital contact phone number';
COMMENT ON COLUMN hospitals.email IS 'Hospital contact email';
COMMENT ON COLUMN hospitals.location_lat IS 'Hospital location latitude';
COMMENT ON COLUMN hospitals.location_long IS 'Hospital location longitude';
COMMENT ON COLUMN hospitals.type IS 'Hospital type (حكومي/خاص)';
COMMENT ON COLUMN hospitals.image_url IS 'URL of the hospital image';
COMMENT ON COLUMN hospitals.departments IS 'Array of available departments/specialties';
COMMENT ON COLUMN hospitals.is_active IS 'Whether the hospital is currently active';

-- Add check constraints
ALTER TABLE hospitals
ADD CONSTRAINT check_hospital_type 
CHECK (type IN ('حكومي', 'خاص'));

-- Create index for common queries
CREATE INDEX IF NOT EXISTS idx_hospitals_region_type 
ON hospitals(region, type);

CREATE INDEX IF NOT EXISTS idx_hospitals_is_active 
ON hospitals(is_active);

-- Add RLS (Row Level Security) policies
ALTER TABLE hospitals ENABLE ROW LEVEL SECURITY;

-- Policy for viewing active hospitals
CREATE POLICY "View active hospitals" ON hospitals
FOR SELECT
TO authenticated
USING (is_active = true);

-- Policy for admin to manage all hospitals
CREATE POLICY "Admin manage hospitals" ON hospitals
FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM auth.users
    WHERE auth.users.id = auth.uid()
    AND auth.users.role = 'admin'
  )
); 