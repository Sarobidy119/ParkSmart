import '../models/reservation_model.dart';
import '../supabase_client.dart';

class ReservationRepository {
  final SupabaseClientSingleton _supabase = SupabaseClientSingleton();

  Future<ReservationModel> create({
    required String utilisateurId,
    required String parkingId,
    required String placeId,
    required String vehiculeId,
    required DateTime debut,
    required DateTime fin,
    required double montant,
  }) async {
    final client = _supabase.client;

    final res = await client
        .from('reservation')
        .insert({
          'utilisateur_id': utilisateurId,
          'parking_id': parkingId,
          'place_id': placeId,
          'vehicule_id': vehiculeId,
          'debut': debut.toIso8601String(),
          'fin': fin.toIso8601String(),
          'statut': 'en_cours',
          'montant': montant,
        })
        .select('*')
        .single();

    return ReservationModel.fromJson(res);
  }

  Future<List<ReservationModel>> getByUser(String utilisateurId) async {
    final client = _supabase.client;

    final res = await client
        .from('reservation')
        .select('*')
        .eq('utilisateur_id', utilisateurId)
        .order('debut', ascending: false);

    final data = res as List<dynamic>?;
    if (data == null) return [];

    return data
        .map((e) => ReservationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ReservationModel?> getById(String id) async {
    final client = _supabase.client;

    final res =
        await client.from('reservation').select('*').eq('id', id).maybeSingle();

    if (res == null) return null;
    return ReservationModel.fromJson(res);
  }

  Future<void> updateStatus(String reservationId, String statut) async {
    final client = _supabase.client;

    await client
        .from('reservation')
        .update({'statut': statut}).eq('id', reservationId);
  }

  Future<bool> checkConflict({
    required String placeId,
    required DateTime debut,
    required DateTime fin,
  }) async {
    final client = _supabase.client;

    // Overlap check: existing.debut < fin AND existing.fin > debut
    final res = await client
        .from('reservation')
        .select('id')
        .eq('place_id', placeId)
        .lt('debut', fin.toIso8601String())
        .gt('fin', debut.toIso8601String())
        .inFilter('statut', ['en_cours', 'a_venir']);

    final data = res as List<dynamic>?;
    return (data ?? []).isNotEmpty;
  }

  Future<List<ReservationModel>> getActive(String utilisateurId) async {
    final client = _supabase.client;

    final res = await client
        .from('reservation')
        .select('*')
        .eq('utilisateur_id', utilisateurId)
        .inFilter('statut', ['en_cours', 'a_venir']).order('debut',
            ascending: true);

    final data = res as List<dynamic>?;
    if (data == null) return [];

    return data
        .map((e) => ReservationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
