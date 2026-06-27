import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/reservation_model.dart';
import '../../../data/repositories/reservation_repository.dart';

class ReservationState {
  final List<ReservationModel> reservations;
  final bool loading;
  final String? error;

  const ReservationState({
    required this.reservations,
    required this.loading,
    required this.error,
  });

  factory ReservationState.initial() {
    return const ReservationState(
      reservations: [],
      loading: false,
      error: null,
    );
  }

  ReservationState copyWith({
    List<ReservationModel>? reservations,
    bool? loading,
    String? error,
  }) {
    return ReservationState(
      reservations: reservations ?? this.reservations,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

final reservationProvider =
    StateNotifierProvider<ReservationController, ReservationState>((ref) {
  return ReservationController(ReservationRepository());
});

class ReservationController extends StateNotifier<ReservationState> {
  final ReservationRepository _repo;

  ReservationController(this._repo) : super(ReservationState.initial());

  Future<void> loadByUser(String utilisateurId) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final list = await _repo.getByUser(utilisateurId);
      state = state.copyWith(loading: false, reservations: list);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }
}

