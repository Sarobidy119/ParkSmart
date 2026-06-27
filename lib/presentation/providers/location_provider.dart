import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;


class LocationState {
  final LatLng? currentLocation;
  final bool loading;
  final String? error;
  final double? accuracy;

  const LocationState({
    this.currentLocation,
    this.loading = false,
    this.error,
    this.accuracy,
  });

  factory LocationState.initial() {
    return const LocationState(loading: false);
  }

  LocationState copyWith({
    LatLng? currentLocation,
    bool? loading,
    String? error,
    double? accuracy,
  }) {
    return LocationState(
      currentLocation: currentLocation ?? this.currentLocation,
      loading: loading ?? this.loading,
      error: error,
      accuracy: accuracy ?? this.accuracy,
    );
  }
}

final locationProvider =
    StateNotifierProvider<LocationController, LocationState>((ref) {
  return LocationController();
});

class LocationController extends StateNotifier<LocationState> {
  LocationController() : super(LocationState.initial());

  /// Demande et suit la position actuelle de l'utilisateur.
  /// Variante actuelle : on tente de calculer la localisation à partir de l'adresse
  /// (stockée côté user) via Nominatim (gratuit, sans clé).
  ///
  /// Si aucune adresse n'est fournie, fallback sur Antananarivo.
  Future<void> startTracking({String? adresse}) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final fallback = const LatLng(-18.9139, 47.5361);

      final addr = (adresse ?? '').trim();
      if (addr.isEmpty) {
        state = state.copyWith(
          currentLocation: fallback,
          accuracy: 100.0,
          loading: false,
        );
        return;
      }

      // Nominatim: https://nominatim.openstreetmap.org/
      // format jsonv2: https://nominatim.org/release-docs/latest/api/Reverse/#jsonv2
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=jsonv2&q=${Uri.encodeComponent(addr)}&limit=1',
      );

      final res = await http.get(uri);
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw 'Nominatim HTTP ${res.statusCode}';
      }

      final decoded = jsonDecode(res.body);
      if (decoded is! List || decoded.isEmpty) {
        state = state.copyWith(
          currentLocation: fallback,
          accuracy: 100.0,
          loading: false,
        );
        return;
      }

      final first = decoded.first as Map<String, dynamic>;
      final lat = double.tryParse(first['lat']?.toString() ?? '');
      final lon = double.tryParse(first['lon']?.toString() ?? '');
      if (lat == null || lon == null) {
        state = state.copyWith(
          currentLocation: fallback,
          accuracy: 100.0,
          loading: false,
        );
        return;
      }

      state = state.copyWith(
        currentLocation: LatLng(lat, lon),
        accuracy: 250.0,
        loading: false,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }


  void updateLocation(LatLng location, {double? accuracy}) {
    state = state.copyWith(
      currentLocation: location,
      accuracy: accuracy,
      error: null,
    );
  }

  Future<void> stopTracking() async {
    state = state.copyWith(currentLocation: null);
  }
}
