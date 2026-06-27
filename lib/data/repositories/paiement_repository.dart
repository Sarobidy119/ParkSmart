import '../models/paiement_model.dart';
import '../supabase_client.dart';

class PaiementRepository {
  final SupabaseClientSingleton _supabase = SupabaseClientSingleton();

  Future<PaiementModel> create({
    required String reservationId,
    required String utilisateurId,
    required String methode,
    required double montant,
  }) async {
    final client = _supabase.client;

    final res = await client
        .from('paiement')
        .insert({
          'reservation_id': reservationId,
          'utilisateur_id': utilisateurId,
          'methode': methode,
          'montant': montant,
          'statut': 'paye',
          'created_at': DateTime.now().toIso8601String(),
        })
        .select('*')
        .single();

    return PaiementModel.fromJson(res);
  }

  Future<void> updateStatus(String paiementId, String statut) async {
    final client = _supabase.client;
    await client
        .from('paiement')
        .update({'statut': statut}).eq('id', paiementId);
  }

  Future<List<PaiementModel>> getByUser(String utilisateurId) async {
    final client = _supabase.client;
    final res = await client
        .from('paiement')
        .select('*')
        .eq('utilisateur_id', utilisateurId)
        .order('created_at', ascending: false);

    final data = res as List<dynamic>?;
    if (data == null) return [];

    return data
        .map((e) => PaiementModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
