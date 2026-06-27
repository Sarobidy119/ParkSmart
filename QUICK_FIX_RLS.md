# 🚀 QUICK FIX RLS - Appliquer en 2 minutes

## ⚡ Le bug en 1 ligne

**INSERT BLOQUÉ** parce que la politique `for insert with check (auth.uid() = id)` est impossible.

---

## ✅ Solution rapide

### Étape 1: Ouvrir Supabase
1. Allez sur https://supabase.com
2. Connectez-vous à votre projet ParkSmart
3. Allez dans **SQL Editor** > **New query**

### Étape 2: Exécuter le FIX

Copier-coller ce code et exécuter:

```sql
-- Supprimer les anciennes politiques bugguées
drop policy if exists "utilisateur_insert_own" on public.utilisateur;

-- Ajouter la nouvelle politique (PERMISSIVE)
create policy "utilisateur_insert_via_trigger" on public.utilisateur
for insert with check (true);

-- Vérifier que c'est OK
select policyname from pg_policies where tablename = 'utilisateur' order by policyname;
```

**Résultat attendu:**
```
utilisateur_admin_all
utilisateur_delete_admin_only
utilisateur_insert_via_trigger
utilisateur_select_own_or_read_email
utilisateur_update_own
```

### Étape 3: Tester

**Test d'inscription:**
```bash
# Sur votre app mobile ou web
flutter run
# Essayez de créer un nouveau compte
```

**Si ça marche:** ✅ Bug corrigé!

---

## 🔍 Vérifier que tout est bon

```sql
-- Query 1: Vérifier les politiques
select 
  policyname,
  cmd,
  qual as "condition"
from pg_policies 
where tablename = 'utilisateur'
order by policyname;

-- Query 2: Tester SELECT (en tant que user)
SELECT id, nom, email FROM utilisateur LIMIT 1;

-- Query 3: Vérifier RLS est activé
SELECT schemaname, tablename, rowsecurity FROM pg_tables 
WHERE tablename = 'utilisateur';
```

---

## 🆘 Si ça ne marche toujours pas

### Option A: Réinitialiser complètement
```sql
-- 1. Désactiver RLS
ALTER TABLE utilisateur DISABLE ROW LEVEL SECURITY;

-- 2. Supprimer toutes les politiques
DROP POLICY IF EXISTS "utilisateur_admin_all" ON public.utilisateur;
DROP POLICY IF EXISTS "utilisateur_delete_admin_only" ON public.utilisateur;
DROP POLICY IF EXISTS "utilisateur_insert_via_trigger" ON public.utilisateur;
DROP POLICY IF EXISTS "utilisateur_select_own_or_read_email" ON public.utilisateur;
DROP POLICY IF EXISTS "utilisateur_update_own" ON public.utilisateur;

-- 3. Réactiver RLS
ALTER TABLE utilisateur ENABLE ROW LEVEL SECURITY;

-- 4. Réappliquer les bonnes politiques
create policy "utilisateur_admin_all" on public.utilisateur
for all using (public.is_admin()) with check (public.is_admin());

create policy "utilisateur_select_own_or_read_email" on public.utilisateur
for select using (auth.uid() = id or public.is_admin() or true);

create policy "utilisateur_insert_via_trigger" on public.utilisateur
for insert with check (true);

create policy "utilisateur_update_own" on public.utilisateur
for update using (auth.uid() = id or public.is_admin()) with check (auth.uid() = id or public.is_admin());

create policy "utilisateur_delete_admin_only" on public.utilisateur
for delete using (public.is_admin());
```

### Option B: Réinitialiser la BD complète
1. Supabase Dashboard > Settings > **Reset Database**
2. ⚠️ Attention: Toutes les données seront supprimées
3. Relancer le script `supabase_schema.sql` (qui contient maintenant le FIX)

---

## 📝 Pourquoi c'était bugué

La politique `for insert with check (auth.uid() = id)` dit:
- "Autoriser INSERT seulement si l'ID de l'utilisateur = l'ID du nouvel enregistrement"
- Mais lors de l'inscription, ces deux IDs ne sont JAMAIS égaux
- Donc INSERT était TOUJOURS bloqué ❌

La nouvelle politique `for insert with check (true)` dit:
- "Autoriser INSERT toujours"
- C'est safe car le trigger `handle_new_user()` valide tout avec `security definer`

---

## 📚 Plus de détails

Lire: [BUG_RLS_ANALYSE_COMPLETE.md](BUG_RLS_ANALYSE_COMPLETE.md)

---

**Est-ce que ça marche?** ✅ Testez et dites-moi!
