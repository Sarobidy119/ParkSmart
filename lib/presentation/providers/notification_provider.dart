import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/notification_model.dart';
import '../../../data/repositories/notification_repository.dart';

class NotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;
  final bool loading;
  final String? error;

  const NotificationState({
    required this.notifications,
    required this.unreadCount,
    required this.loading,
    required this.error,
  });

  factory NotificationState.initial() {
    return const NotificationState(
      notifications: [],
      unreadCount: 0,
      loading: false,
      error: null,
    );
  }

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    int? unreadCount,
    bool? loading,
    String? error,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

final notificationProvider =
    StateNotifierProvider<NotificationController, NotificationState>((ref) {
  return NotificationController(NotificationRepository());
});

class NotificationController extends StateNotifier<NotificationState> {
  final NotificationRepository _repo;

  NotificationController(this._repo) : super(NotificationState.initial());

  Future<void> loadByUser(String utilisateurId) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final list = await _repo.getByUser(utilisateurId);
      final count = list.where((n) => !n.lu).length;
      state = state.copyWith(
        loading: false,
        notifications: list,
        unreadCount: count,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> markAsRead(String utilisateurId, String notificationId) async {
    await _repo.markAsRead(notificationId);
    await loadByUser(utilisateurId);
  }
}

