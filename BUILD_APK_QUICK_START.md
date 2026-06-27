# 🚀 QUICK START - Build APK ParkSmart

## En 3 étapes!

### 1️⃣ Préparez votre environnement
```bash
# Vérifier Flutter
flutter --version

# Vérifier Android
flutter doctor

# Récupérer les dépendances
flutter pub get
```

### 2️⃣ Compilez l'APK Release

**Option la plus simple (recommandée):**
```powershell
.\build_apk_release_v2.ps1
```

**Ou manuellement:**
```bash
flutter build apk --release
```

### 3️⃣ Trouvez votre APK
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## ✅ C'est tout!

Votre APK est prête à être:
- Testée sur un appareil/émulateur
- Signée pour le Play Store
- Partagée avec d'autres

---

## 📝 Si vous devez modifier la config Supabase

Les clés sont automatiquement incluses lors du build via:
- `.env` (fichier local)
- `--dart-define` (lors de la compilation)

**Pour les modifier:**
1. Éditez `.env`
2. Relancez: `flutter build apk --release`

---

## 🆘 En cas de problème

**"Configuration Supabase manquante"**
→ Vérifiez que `.env` existe et contient les bonnes clés

**"Flutter not found"**
→ Installez Flutter depuis https://flutter.dev

**"Gradle build error"**
→ Lancez `flutter clean` puis `flutter pub get`

---

## 📞 Besoin d'aide?

Consultez les guides:
- `GUIDE_BUILD_APK.md` - Guide complet des builds
- `SUPABASE_ARCHITECTURE.md` - Architecture de la BD
- `SUPABASE_CONFIG_COMPLETED.md` - Récapitulatif config
