create type public.app_role as enum ('admin','hospital_staff','user');
create type public.donation_status as enum ('matching_aceptado','en_camino','en_establecimiento','en_tamizaje','donacion_realizada','exitosa','cancelada','no_concretada');
create type public.request_status as enum ('en_proceso','atendida','cancelada');

create table public.health_establishments (
  id uuid primary key default gen_random_uuid(),
  name text not null, address text not null,
  latitude double precision, longitude double precision,
  active boolean not null default true,
  created_at timestamptz not null default now());

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  first_names text not null default '', last_names text not null default '',
  document_type text not null default 'DNI', document_number text not null default '',
  email text not null, phone text not null default '',
  blood_group text, rh_factor text,
  donor_available boolean not null default false,
  donor_fitness text not null default 'pendiente',
  establishment_id uuid references public.health_establishments(id),
  notifications jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now());

create table public.user_roles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  role public.app_role not null, unique (user_id, role));

create table public.blood_requests (
  id uuid primary key default gen_random_uuid(),
  code text not null unique, establishment_id uuid not null references public.health_establishments(id),
  requester_id uuid, patient_name text not null, patient_document text not null,
  blood_group text not null, rh_factor text not null, urgency text not null,
  units_required integer not null, units_fulfilled integer not null default 0,
  searching boolean not null default true,
  status public.request_status not null default 'en_proceso',
  closed_at timestamptz, created_at timestamptz not null default now());

create table public.donations (
  id uuid primary key default gen_random_uuid(),
  request_id uuid not null references public.blood_requests(id) on delete cascade,
  donor_id uuid not null, status public.donation_status not null default 'matching_aceptado',
  estimated_arrival timestamptz, fitness text, fitness_reason text,
  hemoglobin numeric, pulse integer, blood_pressure text,
  completed_at timestamptz, cancelled_at timestamptz,
  created_at timestamptz not null default now());

create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null, kind text not null, title text not null, message text not null,
  read_at timestamptz, created_at timestamptz not null default now());

grant select on public.health_establishments to anon, authenticated;
grant select, insert, update on public.profiles to authenticated;
grant select on public.user_roles to authenticated;
grant select, insert, update on public.blood_requests to authenticated;
grant select, insert, update on public.donations to authenticated;
grant select, update on public.notifications to authenticated;
grant all on public.health_establishments, public.profiles, public.user_roles, public.blood_requests, public.donations, public.notifications to service_role;

alter table public.health_establishments enable row level security;
alter table public.profiles enable row level security;
alter table public.user_roles enable row level security;
alter table public.blood_requests enable row level security;
alter table public.donations enable row level security;
alter table public.notifications enable row level security;

create or replace function public.has_role(_user_id uuid, _role public.app_role)
returns boolean language sql stable security definer set search_path = public
as $$ select exists (select 1 from public.user_roles where user_id = _user_id and role = _role) $$;

create policy "establishments readable" on public.health_establishments for select using (true);
create policy "own profile read" on public.profiles for select to authenticated using (id = auth.uid() or public.has_role(auth.uid(),'admin') or public.has_role(auth.uid(),'hospital_staff'));
create policy "own profile insert" on public.profiles for insert to authenticated with check (id = auth.uid());
create policy "own profile update" on public.profiles for update to authenticated using (id = auth.uid());
create policy "own roles read" on public.user_roles for select to authenticated using (user_id = auth.uid());
create policy "requests read" on public.blood_requests for select to authenticated using (true);
create policy "staff create requests" on public.blood_requests for insert to authenticated with check (public.has_role(auth.uid(),'admin') or public.has_role(auth.uid(),'hospital_staff'));
create policy "staff update requests" on public.blood_requests for update to authenticated using (public.has_role(auth.uid(),'admin') or public.has_role(auth.uid(),'hospital_staff'));
create policy "donations read" on public.donations for select to authenticated using (donor_id = auth.uid() or public.has_role(auth.uid(),'admin') or public.has_role(auth.uid(),'hospital_staff'));
create policy "donor creates donation" on public.donations for insert to authenticated with check (donor_id = auth.uid());
create policy "donations update" on public.donations for update to authenticated using (donor_id = auth.uid() or public.has_role(auth.uid(),'admin') or public.has_role(auth.uid(),'hospital_staff'));
create policy "own notifications read" on public.notifications for select to authenticated using (user_id = auth.uid());
create policy "own notifications update" on public.notifications for update to authenticated using (user_id = auth.uid());

create or replace function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, email, first_names, last_names)
  values (new.id, new.email, coalesce(new.raw_user_meta_data->>'first_names',''), coalesce(new.raw_user_meta_data->>'last_names',''))
  on conflict (id) do nothing;
  insert into public.user_roles (user_id, role) values (new.id, 'user') on conflict do nothing;
  return new;
end $$;
create trigger on_auth_user_created after insert on auth.users for each row execute function public.handle_new_user();