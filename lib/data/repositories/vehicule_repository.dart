import '../models/vehicule_model.dart';
import '../supabase_client.dart';

class VehiculeRepository {
  final SupabaseClientSingleton _supabase = SupabaseClientSingleton();

  Future<List<VehiculeModel>> getByUser(String utilisateurId) async {
    final client = _supabase.client;

    final res = await client
        .from('vehicule')
        .select('*')
        .eq('utilisateur_id', utilisateurId);

    final data = res as List<dynamic>?;
    if (data == null) return [];

    return data
        .map((e) => VehiculeModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<VehiculeModel> create({
    required String utilisateurId,
    required String plaque,
    required String type,
    required String marque,
    required String modele,
  }) async {
    final client = _supabase.client;

    final res = await client
        .from('vehicule')
        .insert({
          'utilisateur_id': utilisateurId,
          'plaque': plaque,
          'type': type,
          'marque': marque,
          'modele': modele,
        })
        .select('*')
        .single();

    return VehiculeModel.fromJson(res);
  }

  Future<void> delete(String vehiculeId) async {
    final client = _supabase.client;
    await client.from('vehicule').delete().eq('id', vehiculeId);
  }
}
