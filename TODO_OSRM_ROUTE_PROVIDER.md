Plan OSRM (à valider)

1) Ajouter dépendance http dans pubspec.yaml
2) Modifier route_provider.dart
   - calcul route via OSRM /route/v1/driving/{lon1},{lat1};{lon2},{lat2}?overview=full&geometries=geojson&alternatives=false&steps=false
   - parser JSON, remplir waypoints avec la geometry.coordinates (lon,lat)
   - extraire distance (m) et duration (s)
3) Ajouter boutons navigation
4) (Plus tard) Géocodage adresse profil -> locationProvider

