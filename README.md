<<<<<<< HEAD
# ParkSmart (Flutter)

Smart parking management with reservation system for Antananarivo, Madagascar.

> This repository was converted from a single HTML multi-screen prototype into a Flutter app.

## Tech stack
- Flutter
- Supabase (PostgreSQL)
- Riverpod (state management)
- GoRouter (navigation)
- flutter_map + OpenStreetMap tiles
- qr_flutter (QR generation)

## Setup
1. Install Flutter stable and Android Studio.
2. Open this folder in Android Studio: `D:\APK\projet-dev-mobile`.
3. Install dependencies:
```bash
flutter pub get
```
4. Configure Supabase credentials when running or building:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`

## Supabase
1. Create a Supabase project.
2. Open `SQL Editor` and execute `supabase_schema.sql`.
3. Go to `Project Settings > API`.
4. Copy `Project URL` as `SUPABASE_URL`.
5. Copy the public `anon` key as `SUPABASE_ANON_KEY`.
6. In `Authentication > Providers > Email`, enable email/password signup.

## Guide complet
Pour la configuration Supabase, la traduction et les commandes de livraison,
consultez `GUIDE_CONFIGURATION_TRADUCTION.md`.

## Run (Android)
```bash
flutter run -d android ^
  --dart-define=SUPABASE_URL=https://your-project.supabase.co ^
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

## Build APK (release)
```bash
flutter build apk --release --no-tree-shake-icons ^
  --dart-define=SUPABASE_URL=https://your-project.supabase.co ^
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

## APK output location
`build/app/outputs/flutter-apk/app-release.apk`

## Notes
- This app uses Supabase tables already created in the backend.
- For a Play Store release, replace the debug release signing in
  `android/app/build.gradle.kts` with a real upload keystore.

=======
# Add a documentation to README.md

# ParkSmart
Gestion de parking intelligent avec réservation de place
>>>>>>> 9fe19b64dd8a5a84ca336a7a69a60f50a2dbdb40
