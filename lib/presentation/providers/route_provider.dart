import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;


class RouteInfo {
  final LatLng startPoint;
  final LatLng endPoint;
  final double distanceMeters;
  final int durationSeconds;
  final List<LatLng> waypoints;

  const RouteInfo({
    required this.startPoint,
    required this.endPoint,
    required this.distanceMeters,
    required this.durationSeconds,
    this.waypoints = const [],
  });

  /// Distance en km
  double get distanceKm => distanceMeters / 1000;

  /// Durée formatée (ex: "15 min")
  String get formattedDuration {
    if (durationSeconds < 60) {
      return '${durationSeconds}s';
    } else if (durationSeconds < 3600) {
      final minutes = (durationSeconds / 60).toStringAsFixed(0);
      return '${minutes}min';
    } else {
      final hours = durationSeconds ~/ 3600;
      final minutes = ((durationSeconds % 3600) / 60).toStringAsFixed(0);
      return '${hours}h ${minutes}min';
    }
  }

  /// Distance formatée (ex: "2.5 km")
  String get formattedDistance {
    if (distanceMeters < 1000) {
      return '${distanceMeters.toStringAsFixed(0)}m';
    }
    return '${distanceKm.toStringAsFixed(1)} km';
  }
}

class RouteState {
  final RouteInfo? route;
  final bool loading;
  final String? error;

  const RouteState({
    this.route,
    this.loading = false,
    this.error,
  });

  factory RouteState.initial() {
    return const RouteState(loading: false);
  }

  RouteState copyWith({
    RouteInfo? route,
    bool? loading,
    String? error,
  }) {
    return RouteState(
      route: route ?? this.route,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

final routeProvider =
    StateNotifierProvider<RouteController, RouteState>((ref) {
  return RouteController();
});

class RouteController extends StateNotifier<RouteState> {
  RouteController() : super(RouteState.initial());

  /// Calcule un itinéraire via OSRM (OpenStreetMap)
  /// Fait une requête /route/v1/driving/{lon1},{lat1};{lon2},{lat2}
  /// et reconstruit la polyline à partir de la geometry GeoJSON.
  Future<void> calculateRoute(LatLng start, LatLng end) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final lon1 = start.longitude;
      final lat1 = start.latitude;
      final lon2 = end.longitude;
      final lat2 = end.latitude;

      final url =
          'https://router.project-osrm.org/route/v1/driving/$lon1,$lat1;$lon2,$lat2?overview=full&geometries=geojson&alternatives=false&steps=false';

      final uri = Uri.parse(url);

      final response = await _httpGetJson(uri);

      final routes = response['routes'];
      if (routes == null || routes is! List || routes.isEmpty) {
        throw 'OSRM: réponse invalide (routes vide)';
      }

      final first = routes.first as Map<String, dynamic>;

      final distanceMeters = (first['distance'] as num).toDouble();
      final durationSeconds = (first['duration'] as num).toDouble().toInt();

      final geometry = first['geometry'] as Map<String, dynamic>;
      final coordinates = geometry['coordinates'];
      if (coordinates == null || coordinates is! List) {
        throw 'OSRM: geometry.coordinates manquants';
      }

      // coordinates = [ [lon,lat], [lon,lat], ... ]
      final waypoints = coordinates
          .whereType<List>()
          .map((pair) {
            if (pair.length < 2) return null;
            final lon = (pair[0] as num).toDouble();
            final lat = (pair[1] as num).toDouble();
            return LatLng(lat, lon);
          })
          .whereType<LatLng>()
          .toList(growable: false);

      final route = RouteInfo(
        startPoint: start,
        endPoint: end,
        distanceMeters: distanceMeters,
        durationSeconds: durationSeconds,
        waypoints: waypoints.isNotEmpty ? waypoints : [start, end],
      );

      state = state.copyWith(route: route, loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<Map<String, dynamic>> _httpGetJson(Uri uri) async {
    final res = await http.get(uri);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw 'OSRM HTTP ${res.statusCode}: ${res.body}';
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! Map<String, dynamic>) {
      throw 'OSRM: JSON non attendu';
    }
    return decoded;
  }


  /// Calcule la distance en mètres entre deux points (Haversine)
  double _calculateDistance(LatLng p1, LatLng p2) {
    const earthRadiusMeters = 6371000.0; // Rayon de la Terre en mètres

    final lat1Rad = _toRadians(p1.latitude);
    final lat2Rad = _toRadians(p2.latitude);
    final deltaLat = _toRadians(p2.latitude - p1.latitude);
    final deltaLng = _toRadians(p2.longitude - p1.longitude);

    final a = math.sin(deltaLat / 2) * math.sin(deltaLat / 2) +
        math.cos(lat1Rad) *
            math.cos(lat2Rad) *
            math.sin(deltaLng / 2) *
            math.sin(deltaLng / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusMeters * c;
  }

  double _toRadians(double degrees) {
    return degrees * math.pi / 180;
  }
}

