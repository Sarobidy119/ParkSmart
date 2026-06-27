# Configuration Supabase - Récapitulatif ParkSmart

## ✅ Configuration complétée

Toutes les configurations Supabase pour vos applications mobile et web sont maintenant **PRÊTES**.

---

## 📱 Application Mobile (Flutter)

### Fichiers configurés:
- ✅ `lib/main.dart` - Initialisation Supabase
- ✅ `.env` - Variables d'environnement
- ✅ `lib/core/constants/supabase_config.dart` - Constants centralisés
- ✅ `.env.example` - Template de configuration

### Credentials Supabase:
```
URL: https://knzoqcvlxmgsxgooizuk.supabase.co
Anon Key: (configurée dans .env)
```

### Pour compiler l'APK Release:

**Option 1: PowerShell (recommandé)**
```powershell
.\build_apk_release_v2.ps1
# ou avec split APK
.\build_apk_release_v2.ps1 -SplitApk
```

**Option 2: Commande directe**
```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://knzoqcvlxmgsxgooizuk.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtuem9xY3ZseG1nc3hnb29penVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAzNTQwNTcsImV4cCI6MjA5NTkzMDA1N30.wttuOVO3mACoWdhtbJ9pklOwn1J0EwzPVWfjMPmfYnY
```

### APK généré à:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 🌐 Application Web Admin (React)

### Fichiers configurés:
- ✅ `admin-web/src/config/supabase.js` - Client Supabase
- ✅ `admin-web/.env` - Variables d'environnement
- ✅ `admin-web/.env.example` - Template de configuration

### Credentials Supabase:
```
URL: https://knzoqcvlxmgsxgooizuk.supabase.co
Anon Key: (configurée dans .env)
```

### Pour lancer la web admin:
```bash
cd admin-web
npm install
npm run dev
```

L'app accèdera à `http://localhost:5173` (Vite)

---

## 🔐 Base de données partagée

**Les deux applications utilisent la MÊME base de données Supabase:**
- ✅ Même URL
- ✅ Même clé anonyme (anon key)
- ✅ Même schéma SQL

Cela signifie:
- Un utilisateur qui se connecte sur mobile/web accède aux mêmes données
- Les réservations faites sur mobile sont visibles sur web
- L'admin web gère les parkings accessibles sur mobile

---

## 📋 Checklist avant le build final

Avant de compiler l'APK final, vérifiez:

- [ ] **Flutter**: `flutter --version` fonctionne
- [ ] **Java SDK**: JDK 11 ou plus (`java -version`)
- [ ] **Android SDK**: Configuré (`flutter doctor`)
- [ ] **Credentials Supabase**: Vérifiés dans `.env`
- [ ] **Dépendances**: À jour (`flutter pub get`)
- [ ] **Clés de signature**: Prêtes si publication play store

---

## 📚 Documentation générale

Pour plus de détails, consultez:
- **GUIDE_BUILD_APK.md** - Commandes de build détaillées
- **SUPABASE_ARCHITECTURE.md** - Architecture et structure DB
- **admin-web/GUIDE_DEMARRAGE.md** - Guide web
- **admin-web/STRUCTURE_PROJET.md** - Structure du projet web

---

## 🚀 Prochaines étapes

1. **Compilez l'APK**: Utilisez le script PowerShell ou les commandes Flutter
2. **Testez sur un appareil/émulateur**: Vérifiez que tout fonctionne
3. **Signez l'APK**: Si vous publiez sur Play Store
4. **Déployez**: Versioning, release notes, etc.

---

## ⚠️ Important

**Ne JAMAIS** committer les fichiers `.env` avec les clés réelles sur Git!
- Le `.env` est dans `.gitignore`
- Utilisez uniquement `.env.example` comme template public

**Si vous publiez:** Considérez une clé de service (service_role_key) avec permissions limitées ou une fonction Supabase pour les opérations sensibles.

---

**Configuration finalisée le:** 2026-06-07
**Projet:** ParkSmart Mobile + Web Admin
