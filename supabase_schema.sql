-- ParkSmart - schema Supabase minimum pour faire fonctionner l'inscription,
-- les parkings, vehicules, reservations, paiements, avis et notifications.
-- A executer dans Supabase > SQL Editor > New query.

create extension if not exists "pgcrypto";

create table if not exists public.utilisateur (
  id uuid primary key references auth.users(id) on delete cascade,
  nom text not null,
  prenom text not null,
  email text not null unique,
  telephone text not null,
  is_admin boolean not null default false,
  created_at timestamptz not null default now()
);

alter table public.utilisateur
add column if not exists is_admin boolean not null default false;

create or replace function public.is_admin()
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1
    from public.utilisateur u
    where u.id = auth.uid()
      and u.is_admin = true
  );
$$;

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.utilisateur (id, nom, prenom, email, telephone)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'nom', ''),
    coalesce(new.raw_user_meta_data ->> 'prenom', ''),
    coalesce(new.email, ''),
    coalesce(new.raw_user_meta_data ->> 'telephone', '')
  )
  on conflict (id) do update set
    nom = excluded.nom,
    prenom = excluded.prenom,
    email = excluded.email,
    telephone = excluded.telephone;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

insert into public.utilisateur (id, nom, prenom, email, telephone)
select
  u.id,
  coalesce(u.raw_user_meta_data ->> 'nom', ''),
  coalesce(u.raw_user_meta_data ->> 'prenom', ''),
  coalesce(u.email, ''),
  coalesce(u.raw_user_meta_data ->> 'telephone', '')
from auth.users u
where not exists (
  select 1 from public.utilisateur p where p.id = u.id
);

create table if not exists public.parking (
  id uuid primary key default gen_random_uuid(),
  nom text not null,
  adresse text not null,
  latitude double precision not null default 0,
  longitude double precision not null default 0,
  ville text not null default 'Antananarivo',
  description text not null default '',
  created_at timestamptz not null default now()
);

create table if not exists public.place_parking (
  id uuid primary key default gen_random_uuid(),
  parking_id uuid not null references public.parking(id) on delete cascade,
  numero text not null,
  occupe boolean not null default false,
  niveau text not null default 'RDC'
);

create table if not exists public.tarif (
  id uuid primary key default gen_random_uuid(),
  parking_id uuid not null references public.parking(id) on delete cascade,
  prix_heure numeric not null default 0,
  prix_jour numeric not null default 0,
  created_at timestamptz not null default now(),
  unique (parking_id)
);

create unique index if not exists tarif_parking_id_key
on public.tarif(parking_id);

create table if not exists public.vehicule (
  id uuid primary key default gen_random_uuid(),
  utilisateur_id uuid not null references public.utilisateur(id) on delete cascade,
  plaque text not null,
  type text not null default 'voiture',
  marque text not null default '',
  modele text not null default '',
  created_at timestamptz not null default now()
);

create table if not exists public.reservation (
  id uuid primary key default gen_random_uuid(),
  utilisateur_id uuid not null references public.utilisateur(id) on delete cascade,
  parking_id uuid not null references public.parking(id) on delete cascade,
  place_id uuid not null references public.place_parking(id) on delete cascade,
  vehicule_id uuid not null references public.vehicule(id) on delete cascade,
  debut timestamptz not null,
  fin timestamptz not null,
  statut text not null default 'a_venir',
  montant numeric not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.paiement (
  id uuid primary key default gen_random_uuid(),
  reservation_id uuid not null references public.reservation(id) on delete cascade,
  utilisateur_id uuid not null references public.utilisateur(id) on delete cascade,
  methode text not null,
  montant numeric not null default 0,
  statut text not null default 'paye',
  created_at timestamptz not null default now()
);

create table if not exists public.avis (
  id uuid primary key default gen_random_uuid(),
  parking_id uuid not null references public.parking(id) on delete cascade,
  utilisateur_id uuid not null references public.utilisateur(id) on delete cascade,
  note integer not null check (note between 1 and 5),
  commentaire text not null default '',
  created_at timestamptz not null default now()
);

create table if not exists public.notification (
  id uuid primary key default gen_random_uuid(),
  utilisateur_id uuid not null references public.utilisateur(id) on delete cascade,
  titre text not null,
  message text not null,
  lu boolean not null default false,
  created_at timestamptz not null default now()
);

alter table public.utilisateur enable row level security;
alter table public.parking enable row level security;
alter table public.place_parking enable row level security;
alter table public.tarif enable row level security;
alter table public.vehicule enable row level security;
alter table public.reservation enable row level security;
alter table public.paiement enable row level security;
alter table public.avis enable row level security;
alter table public.notification enable row level security;

-- Politiques RLS pour table utilisateur - CORRIGÉES
drop policy if exists "utilisateur_admin_all" on public.utilisateur;
drop policy if exists "utilisateur_select_own" on public.utilisateur;
drop policy if exists "utilisateur_insert_own" on public.utilisateur;
drop policy if exists "utilisateur_update_own" on public.utilisateur;
drop policy if exists "utilisateur_insert_via_trigger" on public.utilisateur;
drop policy if exists "utilisateur_delete_admin_only" on public.utilisateur;

-- Admins font tout
create policy "utilisateur_admin_all" on public.utilisateur
for all using (public.is_admin()) with check (public.is_admin());

-- Chacun peut lire son profil (et tous peuvent voir les emails pour contact)
create policy "utilisateur_select_own_or_read_email" on public.utilisateur
for select using (auth.uid() = id or public.is_admin() or true);

-- INSERT via trigger (security definer) - PERMISSIVE
create policy "utilisateur_insert_via_trigger" on public.utilisateur
for insert with check (true);

-- UPDATE - chacun son profil
create policy "utilisateur_update_own" on public.utilisateur
for update using (auth.uid() = id or public.is_admin()) with check (auth.uid() = id or public.is_admin());

-- DELETE - admins seulement
create policy "utilisateur_delete_admin_only" on public.utilisateur
for delete using (public.is_admin());

drop policy if exists "parking_read_all" on public.parking;
create policy "parking_read_all" on public.parking
for select using (true);

drop policy if exists "parking_admin_all" on public.parking;
create policy "parking_admin_all" on public.parking
for all using (public.is_admin()) with check (public.is_admin());

drop policy if exists "place_parking_read_all" on public.place_parking;
create policy "place_parking_read_all" on public.place_parking
for select using (true);

drop policy if exists "place_parking_admin_all" on public.place_parking;
create policy "place_parking_admin_all" on public.place_parking
for all using (public.is_admin()) with check (public.is_admin());

drop policy if exists "tarif_read_all" on public.tarif;
create policy "tarif_read_all" on public.tarif
for select using (true);

drop policy if exists "tarif_admin_all" on public.tarif;
create policy "tarif_admin_all" on public.tarif
for all using (public.is_admin()) with check (public.is_admin());

drop policy if exists "vehicule_crud_own" on public.vehicule;
create policy "vehicule_crud_own" on public.vehicule
for all using (auth.uid() = utilisateur_id or public.is_admin()) with check (auth.uid() = utilisateur_id or public.is_admin());

drop policy if exists "reservation_crud_own" on public.reservation;
create policy "reservation_crud_own" on public.reservation
for all using (auth.uid() = utilisateur_id or public.is_admin()) with check (auth.uid() = utilisateur_id or public.is_admin());

drop policy if exists "paiement_crud_own" on public.paiement;
create policy "paiement_crud_own" on public.paiement
for all using (auth.uid() = utilisateur_id or public.is_admin()) with check (auth.uid() = utilisateur_id or public.is_admin());

drop policy if exists "avis_read_all" on public.avis;
create policy "avis_read_all" on public.avis
for select using (true);

drop policy if exists "avis_insert_own" on public.avis;
create policy "avis_insert_own" on public.avis
for insert with check (auth.uid() = utilisateur_id);

drop policy if exists "avis_admin_all" on public.avis;
create policy "avis_admin_all" on public.avis
for all using (public.is_admin()) with check (public.is_admin());

drop policy if exists "notification_crud_own" on public.notification;
create policy "notification_crud_own" on public.notification
for all using (auth.uid() = utilisateur_id or public.is_admin()) with check (auth.uid() = utilisateur_id or public.is_admin());

insert into public.parking (nom, adresse, latitude, longitude, ville, description)
values
  ('Parking Analakely', 'Analakely, Antananarivo', -18.9101, 47.5257, 'Antananarivo', 'Parking proche du centre-ville.'),
  ('Parking Ankorondrano', 'Ankorondrano, Antananarivo', -18.8792, 47.5222, 'Antananarivo', 'Parking quartier affaires.'),
  ('Parking Ivandry', 'Ivandry, Antananarivo', -18.8667, 47.5298, 'Antananarivo', 'Parking residentiel et commerce.')
on conflict do nothing;

insert into public.place_parking (parking_id, numero, niveau)
select p.id, 'A-' || n::text, 'RDC'
from public.parking p
cross join generate_series(1, 5) as n
where not exists (
  select 1 from public.place_parking pp where pp.parking_id = p.id
);

insert into public.tarif (parking_id, prix_heure, prix_jour)
select p.id, 2000, 15000
from public.parking p
where not exists (
  select 1 from public.tarif t where t.parking_id = p.id
);
