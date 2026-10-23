-- Copy the full donor profile from registration metadata on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
begin
  insert into public.profiles (id, email, first_names, last_names, document_type, document_number, phone, blood_group, rh_factor)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'first_names',''),
    coalesce(new.raw_user_meta_data->>'last_names',''),
    coalesce(new.raw_user_meta_data->>'document_type','DNI'),
    coalesce(new.raw_user_meta_data->>'document_number',''),
    coalesce(new.raw_user_meta_data->>'phone',''),
    nullif(new.raw_user_meta_data->>'blood_group',''),
    nullif(new.raw_user_meta_data->>'rh_factor','')
  )
  on conflict (id) do nothing;
  insert into public.user_roles (user_id, role) values (new.id, 'user') on conflict do nothing;
  return new;
end
$function$;

-- Reference data: health network establishments that blood requests reference
INSERT INTO public.health_establishments (name, address, latitude, longitude, active) VALUES
  ('Hospital Nacional Dos de Mayo', 'Av. Grau 13, Lima', -12.0464, -77.0428, true),
  ('Hospital Edgardo Rebagliati', 'Av. Rebagliati 490, Jesús María', -12.0742, -77.0487, true),
  ('Clínica Internacional', 'Av. Washington 1475, Lima', -12.0653, -77.0369, false);