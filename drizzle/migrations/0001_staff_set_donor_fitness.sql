-- Staff can record a donor's fitness outcome without widening profile update policies
CREATE OR REPLACE FUNCTION public.set_donor_fitness(_donor_id uuid, _fitness text)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
begin
  if not (public.has_role(auth.uid(), 'hospital_staff') or public.has_role(auth.uid(), 'admin')) then
    raise exception 'not authorized';
  end if;
  update public.profiles set donor_fitness = _fitness, updated_at = now() where id = _donor_id;
end
$function$;