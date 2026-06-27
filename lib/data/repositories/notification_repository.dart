import '../models/notification_model.dart';
import '../supabase_client.dart';

class NotificationRepository {
  final SupabaseClientSingleton _supabase = SupabaseClientSingleton();

  Future<List<NotificationModel>> getByUser(String utilisateurId) async {
    final client = _supabase.client;

    final res = await client
        .from('notification')
        .select('*')
        .eq('utilisateur_id', utilisateurId)
        .order('created_at', ascending: false);

    final data = res as List<dynamic>?;
    if (data == null) return [];

    return data
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> markAsRead(String notificationId) async {
    final client = _supabase.client;
    await client
        .from('notification')
        .update({'lu': true}).eq('id', notificationId);
  }

  Future<void> markAllAsRead(String utilisateurId) async {
    final client = _supabase.client;
    await client
        .from('notification')
        .update({'lu': true}).eq('utilisateur_id', utilisateurId);
  }

  Future<int> getUnreadCount(String utilisateurId) async {
    final list = await getByUser(utilisateurId);
    return list.where((n) => !n.lu).length;
  }
}
