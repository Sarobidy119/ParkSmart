# ✅ Vérification de la Configuration Supabase

Ce guide vous permet de vérifier que **mobile ET web utilisent la même base de données**.

---

## 🔍 Vérification Mobile (Flutter)

### 1. Vérifiez le fichier `.env`
```bash
cat .env
```
Vous devriez voir:
```
SUPABASE_URL=https://knzoqcvlxmgsxgooizuk.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### 2. Vérifiez `lib/main.dart`
Les valeurs par défaut doivent correspondre:
```dart
const supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://knzoqcvlxmgsxgooizuk.supabase.co',
);
```

### 3. Vérifiez les constants
```bash
cat lib/core/constants/supabase_config.dart
```

---

## 🌐 Vérification Web (React)

### 1. Vérifiez le fichier `admin-web/.env`
```bash
cat admin-web\.env
```
Vous devriez voir:
```
VITE_SUPABASE_URL=https://knzoqcvlxmgsxgooizuk.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### 2. Vérifiez `admin-web/src/config/supabase.js`
```bash
cat admin-web\src\config\supabase.js
```
Les URLs doivent correspondre à celles dans `.env`

---

## 🔗 Table de vérification

| Paramètre | Mobile | Web | Doit être identique |
|-----------|--------|-----|------------------|
| **Supabase URL** | `lib/main.dart` | `admin-web/.env` | ✅ OUI |
| **Anon Key** | `.env` | `admin-web/.env` | ✅ OUI |
| **Base de données** | Partagée | Partagée | ✅ OUI |
| **Authentification** | Partagée | Partagée | ✅ OUI |

---

## 🧪 Test de synchronisation

### Test 1: Vérifiez l'authentification

**Sur mobile:**
1. Lancez l'app: `flutter run`
2. Inscrivez-vous avec un email: `test@example.com`
3. Notez le timestamp d'inscription

**Sur web:**
1. Lancez l'app: `npm run dev` (dans `admin-web/`)
2. Allez dans Admin > Utilisateurs
3. Cherchez `test@example.com` - Il devrait apparaître

✅ **Si vous voyez le même utilisateur** → Synchronisation OK

### Test 2: Créer une réservation

**Sur mobile:**
1. Créez une réservation de parking
2. Notez l'ID de réservation

**Sur web:**
1. Allez dans Admin > Réservations
2. Cherchez la réservation créée sur mobile

✅ **Si vous voyez la réservation** → Synchronisation OK

---

## ⚙️ Configuration avancée

### Ajouter des tables supplémentaires

1. Allez sur [https://supabase.com](https://supabase.com)
2. Connectez-vous avec votre projet
3. Allez dans SQL Editor
4. Exécutez le contenu de `supabase_schema.sql`

### Modifier les permissions (RLS)

Pour plus de sécurité, configurez Row Level Security (RLS):

```sql
-- Exemple: Les utilisateurs ne voient que leurs propres réservations
ALTER TABLE reservation ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users_see_own_reservations" ON reservation
  FOR SELECT USING (auth.uid() = utilisateur_id);
```

---

## 📊 Quelques statistiques

```bash
# Vérifier la structure de la DB
# (À faire sur Supabase Dashboard)

Tables créées:
- utilisateur
- parking
- place_parking
- tarif
- vehicule
- reservation
- paiement
- avis
- notification
```

---

## 🚨 Dépannage

### La web et mobile ne voient pas les mêmes données

**Cause probable:** URLs ou clés différentes

**Solution:**
1. Vérifiez `.env` (mobile) et `admin-web/.env` (web)
2. Assurez-vous qu'ils pointent vers le MÊME projet Supabase
3. Les clés anon doivent être IDENTIQUES

### L'API retourne une erreur 401 (Unauthorized)

**Cause probable:** Clé anon invalide ou RLS trop restrictif

**Solution:**
1. Vérifiez que la clé anon commence par `eyJ...`
2. Vérifiez les politiques RLS sur les tables
3. Testez avec le Supabase Client directement

### L'authentification ne fonctionne pas

**Cause probable:** Mauvaise configuration Supabase

**Solution:**
1. Allez sur [https://supabase.com](https://supabase.com)
2. Vérifiez que l'authentification email/password est activée
3. Vérifiez les redirect URLs (auth callbacks)

---

## ✅ Checklist de vérification

- [ ] Mobile et Web pointent vers le même projet Supabase
- [ ] Les clés anon sont identiques
- [ ] Les URLs sont identiques
- [ ] L'authentification fonctionne sur mobile
- [ ] L'authentification fonctionne sur web
- [ ] Les données créées sur mobile apparaissent sur web
- [ ] Les données créées sur web apparaissent sur mobile
- [ ] Les permissions RLS sont correctes
- [ ] Les fichiers `.env` sont dans `.gitignore`

---

**Dernière vérification:** 2026-06-07
