# Guide de démarrage rapide - Nouvelles fonctionnalités ParkSmart

## Installation rapide

### Dépendances à ajouter (à faire manuellement dans pubspec.yaml)

```yaml
dependencies:
  # ... existantes ...
  
  # Géolocalisation (recommandé)
  geolocator: ^10.1.0
  
  # Pour les itinéraires avancés (optionnel)
  osm_nominatim: ^0.8.0
  
  # Notifications push (optionnel)
  firebase_messaging: ^14.6.0
```

### Permissions Android

Ajouter à `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

### Permissions iOS

Ajouter à `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Pour afficher votre position sur la carte</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Pour afficher votre position sur la carte</string>
```

---

## Utilisation des nouveaux providers

### Géolocalisation

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'location_provider.dart';

// Dans votre widget
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationState = ref.watch(locationProvider);
    
    // Démarrer le suivi
    ref.read(locationProvider.notifier).startTracking();
    
    // Utiliser la position
    if (locationState.currentLocation != null) {
      return Text('Position: ${locationState.currentLocation}');
    }
    
    return const CircularProgressIndicator();
  }
}
```

### Vues cartographiques

```dart
import 'map_provider.dart';

// Changer la vue
ref.read(mapProvider.notifier).setMapViewType(MapViewType.satellite);

// Obtenir l'URL du tile
final tileUrl = ref.read(mapProvider).getTileUrl();
```

### Itinéraires

```dart
import 'route_provider.dart';

// Calculer un itinéraire
await ref.read(routeProvider.notifier).calculateRoute(
  LatLng(-18.9, 47.5),  // Départ
  LatLng(-18.8, 47.6),  // Arrivée
);

// Accéder aux infos
final route = ref.read(routeProvider).route;
print('Distance: ${route?.formattedDistance}');  // "2.5 km"
print('Durée: ${route?.formattedDuration}');     // "15 min"
```

---

## Intégration réelle avec geolocator

### Remplacer l'implémentation mock

Modifier `lib/presentation/providers/location_provider.dart`:

```dart
// Importer geolocator
import 'package:geolocator/geolocator.dart';

// Dans LocationController.startTracking()
Future<void> startTracking() async {
  state = state.copyWith(loading: true, error: null);
  try {
    // Demander les permissions
    bool hasPermission = await _requestPermission();
    if (!hasPermission) {
      throw 'Permission de localisation refusée';
    }
    
    // Obtenir la position actuelle
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 10),
    );
    
    state = state.copyWith(
      currentLocation: LatLng(position.latitude, position.longitude),
      accuracy: position.accuracy,
      loading: false,
    );
    
    // Écouter les mises à jour en temps réel
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Mettre à jour tous les 10 mètres
      ),
    ).listen((position) {
      updateLocation(
        LatLng(position.latitude, position.longitude),
        accuracy: position.accuracy,
      );
    });
  } catch (e) {
    state = state.copyWith(loading: false, error: e.toString());
  }
}

Future<bool> _requestPermission() async {
  final status = await Geolocator.checkPermission();
  if (status == LocationPermission.denied) {
    return await Geolocator.requestPermission() != 
           LocationPermission.denied;
  }
  return status == LocationPermission.whileInUse || 
         status == LocationPermission.always;
}
```

---

## Structure des réservations - Modèle attendu

```dart
class ReservationModel {
  final String id;
  final String utilisateurId;
  final String parkingId;
  final String placeId;
  final String vehiculeId;
  final DateTime debut;
  final DateTime fin;
  final String statut; // 'en_attente', 'confirmee', 'annulee', 'terminee'
  final double montant;
  
  // Utilisé dans reservation_list_screen.dart
  // Assurez-vous que ces champs existent
}
```

---

## Intégration Supabase - Scripts SQL

### 1. Créer la table des réservations

```sql
CREATE TABLE IF NOT EXISTS reservations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  utilisateur_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  parking_id UUID NOT NULL,
  place_id VARCHAR(50) NOT NULL,
  vehicule_id UUID NOT NULL,
  debut TIMESTAMP WITH TIME ZONE NOT NULL,
  fin TIMESTAMP WITH TIME ZONE NOT NULL,
  statut VARCHAR(50) NOT NULL DEFAULT 'en_attente',
  montant DECIMAL(10, 2) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_reservations_utilisateur 
  ON reservations(utilisateur_id);
CREATE INDEX idx_reservations_parking 
  ON reservations(parking_id);
CREATE INDEX idx_reservations_statut 
  ON reservations(statut);
```

### 2. Activer RLS (Row Level Security)

```sql
ALTER TABLE reservations ENABLE ROW LEVEL SECURITY;

-- Utilisateur ne voit que ses propres réservations
CREATE POLICY "Users can see their own reservations"
  ON reservations FOR SELECT
  USING (auth.uid() = utilisateur_id);

-- Utilisateur peut créer ses propres réservations
CREATE POLICY "Users can create their own reservations"
  ON reservations FOR INSERT
  WITH CHECK (auth.uid() = utilisateur_id);
```

---

## Tester les nouvelles fonctionnalités

### Checklist de test

- [ ] **Carte**: 3 vues (standard, satellite, relief) fonctionnent
- [ ] **Position GPS**: Affiche votre position avec précision
- [ ] **Itinéraire**: Affiche distance/durée corrects
- [ ] **Réservations**: Statuts s'affichent avec bonnes couleurs
- [ ] **Profil**: Affiche toutes les infos, édition fonctionne
- [ ] **Navigation**: Bouton retour fonctionne partout
- [ ] **Admin Web**: Voir les réservations en temps réel

### Exemple de test

```dart
void testNewFeatures() {
  // 1. Tester la géolocalisation
  test('Location tracking works', () async {
    final controller = LocationController();
    await controller.startTracking();
    expect(controller.state.currentLocation, isNotNull);
  });

  // 2. Tester les vues cartographiques
  test('Map view types work', () {
    final mapController = MapController();
    
    mapController.setMapViewType(MapViewType.standard);
    expect(mapController.state.viewType, MapViewType.standard);
    
    mapController.setMapViewType(MapViewType.satellite);
    expect(mapController.state.getTileUrl(), contains('arcgisonline'));
  });

  // 3. Tester les itinéraires
  test('Route calculation works', () async {
    final routeController = RouteController();
    final start = LatLng(-18.9, 47.5);
    final end = LatLng(-18.8, 47.6);
    
    await routeController.calculateRoute(start, end);
    expect(routeController.state.route, isNotNull);
    expect(routeController.state.route!.distanceMeters, greaterThan(0));
  });
}
```

---

## Dépannage

### La géolocalisation ne fonctionne pas

1. Vérifier les permissions dans les settings du téléphone
2. Vérifier que la location n'est pas désactivée
3. Utiliser un appareil réel (l'émulateur a parfois des problèmes)
4. Ajouter `simulateLocation()` pour les tests

### Les boutons de navigation ne fonctionnent pas

1. Vérifier que vous utilisez `context.go()` et non `Navigator.push()`
2. Vérifier que toutes les routes sont définies dans `app_router.dart`
3. Vérifier les logs pour les erreurs de routing

### Les réservations ne s'affichent pas

1. Vérifier la RLS Supabase - l'utilisateur peut-il accéder?
2. Vérifier que `utilisateur_id` correspond à `auth.uid()`
3. Vérifier que les données existent dans Supabase

---

## Documentation complète

Pour plus de détails, voir:
- `MODIFICATIONS_COMPLETE_GUIDE.md` - Vue d'ensemble de tous les changements
- `ADMIN_WEB_INTEGRATION.md` - Intégration backend
- `lib/core/router/NAVIGATION_GUIDE.dart` - Guide de navigation

---

**Dernière mise à jour**: 2026-06-12
**Besoin d'aide?** Consultez les fichiers de documentation listés ci-dessus

