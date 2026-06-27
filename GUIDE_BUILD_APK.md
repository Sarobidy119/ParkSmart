# Guide de compilation APK - ParkSmart Mobile

## Configuration Supabase

Les deux applications (mobile et web) partagent **la même base de données Supabase**:
- **URL**: `https://knzoqcvlxmgsxgooizuk.supabase.co`
- **Clé anonyme**: Déjà configurée dans `.env` et les fichiers

## Compilation du développement (debug)

```bash
# Simple - utilisera les valeurs par défaut
flutter run

# Avec variables d'environnement personnalisées (optionnel)
flutter run \
  --dart-define=SUPABASE_URL=https://knzoqcvlxmgsxgooizuk.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtuem9xY3ZseG1nc3hnb29penVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAzNTQwNTcsImV4cCI6MjA5NTkzMDA1N30.wttuOVO3mACoWdhtbJ9pklOwn1J0EwzPVWfjMPmfYnY
```

## Compilation Release APK

```bash
# Simple - utilisera les valeurs par défaut
flutter build apk --release

# Avec variables d'environnement personnalisées
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://knzoqcvlxmgsxgooizuk.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtuem9xY3ZseG1nc3hnb29penVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAzNTQwNTcsImV4cCI6MjA5NTkzMDA1N30.wttuOVO3mACoWdhtbJ9pklOwn1J0EwzPVWfjMPmfYnY
```

## Compilation Release APK (Split-APKs par ABI)

Pour réduire la taille:

```bash
flutter build apk --split-per-abi --release \
  --dart-define=SUPABASE_URL=https://knzoqcvlxmgsxgooizuk.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtuem9xY3ZseG1nc3hnb29penVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAzNTQwNTcsImV4cCI6MjA5NTkzMDA1N30.wttuOVO3mACoWdhtbJ9pklOwn1J0EwzPVWfjMPmfYnY
```

## APK généré

Le fichier APK sera disponible à:
```
build/app/outputs/flutter-apk/app-release.apk
```

## Dépannage

### Erreur "Configuration Supabase manquante"

Cela signifie que les variables d'environnement n'ont pas été passées correctement lors de la compilation.

**Solution**: Utiliser la commande avec `--dart-define` ou vérifier que la variable par défaut est correcte.

### Configuration Supabase sur les deux plateformes

| Plateforme | Fichier de config | Variables |
|-----------|------------------|-----------|
| **Flutter (Mobile)** | `lib/main.dart` + `.env` | `SUPABASE_URL`, `SUPABASE_ANON_KEY` |
| **React (Web Admin)** | `admin-web/.env` | `VITE_SUPABASE_URL`, `VITE_SUPABASE_ANON_KEY` |

Les deux utilisent les **mêmes clés Supabase** pour accéder à la même base de données.

## Fichiers pertinents

- `.env` - Variables pour le développement
- `.env.example` - Template à copier
- `lib/main.dart` - Initialisation Supabase
- `lib/core/constants/supabase_config.dart` - Configuration centralisée
- `admin-web/.env` - Configuration web pour Vite
