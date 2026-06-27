import 'dart:math';

import '../models/parking_model.dart';
import '../supabase_client.dart';

class ParkingRepository {
  final SupabaseClientSingleton _supabase = SupabaseClientSingleton();

  Future<List<ParkingModel>> getAll() async {
    final client = _supabase.client;

    final res = await client.from('parking').select('*').limit(1000);

    final data = res as List<dynamic>?;
    if (data == null) return [];

    return data
        .map((e) => ParkingModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ParkingModel?> getById(String id) async {
    final client = _supabase.client;

    final res =
        await client.from('parking').select('*').eq('id', id).maybeSingle();

    if (res == null) return null;

    return ParkingModel.fromJson(res);
  }

  Future<List<ParkingModel>> getNearby(
    double lat,
    double lng,
    double radiusKm,
  ) async {
    // PostgreSQL PostGIS ideally, but without schema we do a client-side filter.
    final all = await getAll();

    double distanceKm(ParkingModel p) {
      // Haversine
      const r = 6371.0;
      final dLat = (p.latitude - lat) * (3.1415926535 / 180.0);
      final dLng = (p.longitude - lng) * (3.1415926535 / 180.0);
      final a = (sin(dLat / 2) * sin(dLat / 2)) +
          cos(lat * (3.1415926535 / 180.0)) *
              cos(p.latitude * (3.1415926535 / 180.0)) *
              (sin(dLng / 2) * sin(dLng / 2));
      final c = 2 * atan2(sqrt(a), sqrt(1 - a));
      return r * c;
    }

    return all.where((p) => distanceKm(p) <= radiusKm).toList();
  }
}
