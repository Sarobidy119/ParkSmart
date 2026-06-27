import '../models/avis_model.dart';
import '../supabase_client.dart';

class AvisRepository {
  final SupabaseClientSingleton _supabase = SupabaseClientSingleton();

  Future<List<AvisModel>> getByParking(String parkingId) async {
    final client = _supabase.client;

    final res = await client
        .from('avis')
        .select('*')
        .eq('parking_id', parkingId)
        .order('created_at', ascending: false);

    final data = res as List<dynamic>?;
    if (data == null) return [];

    return data
        .map((e) => AvisModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AvisModel> create({
    required String parkingId,
    required String utilisateurId,
    required int note,
    required String commentaire,
  }) async {
    final client = _supabase.client;

    final res = await client
        .from('avis')
        .insert({
          'parking_id': parkingId,
          'utilisateur_id': utilisateurId,
          'note': note,
          'commentaire': commentaire,
          'created_at': DateTime.now().toIso8601String(),
        })
        .select('*')
        .single();

    return AvisModel.fromJson(res);
  }

  Future<double> getAverageNote(String parkingId) async {
    final avis = await getByParking(parkingId);
    if (avis.isEmpty) return 0;

    final sum = avis.fold<int>(0, (p, e) => p + e.note);
    return sum / avis.length;
  }
}
