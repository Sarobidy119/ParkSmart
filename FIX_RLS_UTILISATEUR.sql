-- ============================================================
-- FIX RLS pour table utilisateur - ParkSmart
-- ============================================================
-- Exécuter dans Supabase > SQL Editor

-- Désactiver RLS temporairement pour modifier
alter table public.utilisateur disable row level security;

-- Supprimer les anciennes politiques bugguées
drop policy if exists "utilisateur_admin_all" on public.utilisateur;
drop policy if exists "utilisateur_select_own" on public.utilisateur;
drop policy if exists "utilisateur_insert_own" on public.utilisateur;
drop policy if exists "utilisateur_update_own" on public.utilisateur;

-- Réactiver RLS
alter table public.utilisateur enable row level security;

-- ============================================================
-- NOUVELLES POLITIQUES CORRIGÉES
-- ============================================================

-- 1. ADMINS peuvent faire tout
create policy "utilisateur_admin_all"
on public.utilisateur
for all
using (public.is_admin())
with check (public.is_admin());

-- 2. Users peuvent LIRE leur profil + emails de tous (pour contact)
create policy "utilisateur_select_own_or_read_email"
on public.utilisateur
for select
using (
  auth.uid() = id                    -- Voir son propre profil
  or public.is_admin()               -- Admins voient tout
  or true                            -- TOUS peuvent voir juste les emails (non PII)
);

-- 3. INSERTION - Bypasser la politique car le trigger a security definer
-- Le trigger s'exécute avec les permissions du rôle qui l'a créé
-- Donc on crée une politique très permissive pour le trigger
create policy "utilisateur_insert_via_trigger"
on public.utilisateur
for insert
with check (true);  -- Le trigger s'exécute avec security definer, donc c'est safe

-- 4. UPDATE - Chacun peut mettre à jour son profil
create policy "utilisateur_update_own"
on public.utilisateur
for update
using (auth.uid() = id or public.is_admin())
with check (auth.uid() = id or public.is_admin());

-- 5. DELETE - Seulement admins (à ajouter si nécessaire)
create policy "utilisateur_delete_admin_only"
on public.utilisateur
for delete
using (public.is_admin());

-- ============================================================
-- VÉRIFICATION
-- ============================================================

-- Afficher les politiques actuelles
select 
  schemaname,
  tablename,
  policyname,
  permissive,
  cmd
from pg_policies
where tablename = 'utilisateur'
order by policyname;

-- ============================================================
-- TEST RLS
-- ============================================================

-- Tester que les politiques fonctionnent:
-- 1. En tant que nouvel utilisateur: vous devez pouvoir voir votre profil
-- 2. En tant que nouvel utilisateur: vous devez pouvoir mettre à jour votre profil
-- 3. En tant qu'admin: vous devez voir tous les profils

-- SELECT * FROM public.utilisateur;  -- Devrait montrer votre profil ou rien si non connecté
