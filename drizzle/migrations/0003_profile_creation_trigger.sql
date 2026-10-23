-- Recreates the signup trigger lost with the cleared migrations: every new auth user gets a profile (with the metadata sent by the registration form) and the default 'user' role.
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, email, first_names, last_names, document_type, document_number, phone, blood_group, rh_factor, donor_available, donor_fitness, notifications)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'first_names', ''),
    COALESCE(NEW.raw_user_meta_data->>'last_names', ''),
    COALESCE(NEW.raw_user_meta_data->>'document_type', 'DNI'),
    COALESCE(NEW.raw_user_meta_data->>'document_number', ''),
    COALESCE(NEW.raw_user_meta_data->>'phone', ''),
    NULLIF(NEW.raw_user_meta_data->>'blood_group', ''),
    NULLIF(NEW.raw_user_meta_data->>'rh_factor', ''),
    true,
    'pendiente',
    '[]'::jsonb
  );
  INSERT INTO public.user_roles (user_id, role) VALUES (NEW.id, 'user') ON CONFLICT DO NOTHING;
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();