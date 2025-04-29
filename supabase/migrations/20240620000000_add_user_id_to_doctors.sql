-- Agregar columna user_id a la tabla de doctores
ALTER TABLE public.doctors
ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id);

-- Agregar índice para búsquedas rápidas
CREATE INDEX IF NOT EXISTS idx_doctors_user_id ON public.doctors(user_id);

-- Agregar comentario a la columna
COMMENT ON COLUMN public.doctors.user_id IS 'ID del usuario asociado al doctor para inicio de sesión';

-- Actualizar la política de seguridad para permitir a los doctores ver y actualizar sus propios datos
CREATE POLICY "Doctors can view and update own data" ON public.doctors
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Función para actualizar el rol del usuario cuando se asocia a un doctor
CREATE OR REPLACE FUNCTION public.update_user_role_to_doctor()
RETURNS TRIGGER AS $$
BEGIN
  -- Si se asigna un user_id, actualizar el rol del usuario a 'Doctor'
  IF NEW.user_id IS NOT NULL THEN
    UPDATE auth.users
    SET role = 'Doctor'
    WHERE id = NEW.user_id;
    
    -- También actualizar en la tabla de perfiles de usuario
    UPDATE public.user_profiles
    SET role = 'Doctor'
    WHERE id = NEW.user_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Crear trigger para actualizar el rol del usuario
DROP TRIGGER IF EXISTS update_doctor_user_role_trigger ON public.doctors;
CREATE TRIGGER update_doctor_user_role_trigger
AFTER INSERT OR UPDATE OF user_id ON public.doctors
FOR EACH ROW
EXECUTE FUNCTION public.update_user_role_to_doctor();

-- Función para sincronizar datos entre doctor y usuario
CREATE OR REPLACE FUNCTION public.sync_doctor_user_data()
RETURNS TRIGGER AS $$
BEGIN
  -- Si el doctor tiene un user_id, actualizar datos relevantes del usuario
  IF NEW.user_id IS NOT NULL THEN
    UPDATE auth.users
    SET email = NEW.email
    WHERE id = NEW.user_id AND NEW.email IS NOT NULL;
    
    -- Actualizar perfil de usuario
    UPDATE public.user_profiles
    SET 
      email = NEW.email,
      full_name = NEW.name_arabic,
      phone = NEW.phone,
      profile_picture = NEW.profile_photo_url
    WHERE id = NEW.user_id AND NEW.email IS NOT NULL;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Crear trigger para sincronizar datos
DROP TRIGGER IF EXISTS sync_doctor_user_data_trigger ON public.doctors;
CREATE TRIGGER sync_doctor_user_data_trigger
AFTER UPDATE OF email, name_arabic, phone, profile_photo_url ON public.doctors
FOR EACH ROW
EXECUTE FUNCTION public.sync_doctor_user_data();
