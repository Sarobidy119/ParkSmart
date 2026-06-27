# ParkSmart - Configuration et traduction

Ce guide sert a rendre l'application utilisable avec Supabase et a savoir ou modifier les textes.

## 1. Logo

L'image utilisee comme logo est:

```text
assets/images/logo.png
```

Elle est maintenant branchee pour:

- le logo installe Android: `android/app/src/main/res/mipmap-*/ic_launcher.png`
- le logo de demarrage natif Android: `android/app/src/main/res/drawable-nodpi/launch_logo.png`
- le splash Flutter: `lib/presentation/screens/splash/splash_screen.dart`
- le logo web admin: `admin-web/public/logo.png`
- l'icone du navigateur: `admin-web/public/favicon.png`
- l'icone iPhone/iPad web: `admin-web/public/apple-touch-icon.png`

Si tu changes `assets/images/logo.png`, il faut regenerer les icones Android et web.

## 2. Configuration Supabase

### A. Creer le projet Supabase

1. Va sur Supabase et cree un projet.
2. Ouvre `Project Settings > API`.
3. Copie:
   - `Project URL`
   - `anon public key`

N'utilise jamais la cle `service_role` dans l'application mobile ou dans le site web.

### B. Creer les tables

1. Ouvre `SQL Editor` dans Supabase.
2. Cree une nouvelle requete.
3. Copie tout le contenu de:

```text
supabase_schema.sql
```

4. Execute le script.

### C. Configurer Auth

Pour les tests rapides:

1. Va dans `Authentication > Providers`.
2. Active `Email`.
3. Dans `Authentication > Settings`, tu peux desactiver la confirmation email pendant les tests.

Pour la production, garde la confirmation email active.

### D. Configurer l'application mobile Flutter

L'app mobile est deja configuree avec ce projet Supabase:

```text
https://knzoqcvlxmgsxgooizuk.supabase.co
```

Tu peux donc compiler l'APK directement avec:

```powershell
flutter build apk --release --no-tree-shake-icons
```

ou avec le script:

```powershell
.\build_apk_release.ps1
```

L'app mobile lit aussi les cles au moment de la compilation avec `--dart-define` si tu veux remplacer la configuration par defaut.

Lancer en debug avec la configuration deja integree:

```powershell
flutter run
```

Compiler un APK avec une autre configuration Supabase, seulement si tu changes de projet:

```powershell
flutter build apk --release --dart-define=SUPABASE_URL=https://votre-projet.supabase.co --dart-define=SUPABASE_ANON_KEY=votre-cle-anon
```

L'APK final sera dans:

```text
build/app/outputs/flutter-apk/app-release.apk
```

### E. Configurer l'admin web

Dans:

```text
admin-web/.env
```

mets:

```env
VITE_SUPABASE_URL=https://knzoqcvlxmgsxgooizuk.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtuem9xY3ZseG1nc3hnb29penVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAzNTQwNTcsImV4cCI6MjA5NTkzMDA1N30.wttuOVO3mACoWdhtbJ9pklOwn1J0EwzPVWfjMPmfYnY
```

Puis lance:

```powershell
.\lancer_admin_web.ps1
```

Pour compiler le site:

```powershell
.\build_admin_web.ps1
```

Le resultat sera dans:

```text
admin-web/dist
```

### F. Creer un compte administrateur

1. Cree un compte via l'application mobile ou via `Authentication > Users`.
2. Dans Supabase, ouvre la table `utilisateur`.
3. Mets `is_admin` a `true` pour ce compte.
4. Connecte-toi ensuite dans l'admin web avec cet email et ce mot de passe.

## 3. Traduire l'application mobile

Les textes principaux Flutter sont centralises dans:

```text
lib/core/constants/app_strings.dart
```

Pour traduire l'application, modifie les valeurs dans ce fichier. Exemple:

```dart
static const String signIn = 'Se connecter';
```

devient:

```dart
static const String signIn = 'Login';
```

Certains textes sont encore ecrits directement dans des ecrans. Pour les trouver:

```powershell
rg -n "'[^']*[A-Za-z][^']*'|\"[^\"]*[A-Za-z][^\"]*\"" lib
```

Ensuite, deplace ces textes vers `AppStrings` pour garder une traduction propre.

## 4. Traduire l'admin web

Les textes du panneau admin sont dans:

```text
admin-web/src/pages/Login.jsx
admin-web/src/pages/AdminLayout.jsx
admin-web/src/pages/AdminPages.jsx
```

Pour une traduction simple, modifie directement les textes visibles dans ces fichiers.

Pour une vraie application multilingue, ajoute une bibliotheque comme `react-i18next`, puis cree des fichiers:

```text
admin-web/src/locales/fr.json
admin-web/src/locales/en.json
admin-web/src/locales/mg.json
```

## 5. Verification avant utilisation

Avant de livrer:

```powershell
flutter test
.\build_apk_release.ps1
.\build_admin_web.ps1
```

Ou lance seulement:

```powershell
.\verifier_projet.ps1
```

L'APK pret a installer est:

```text
build/app/outputs/flutter-apk/app-release.apk
```
