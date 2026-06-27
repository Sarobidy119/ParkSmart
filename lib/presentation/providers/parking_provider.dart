import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/parking_model.dart';
import '../../../data/repositories/parking_repository.dart';

class ParkingState {
  final List<ParkingModel> parkings;
  final bool loading;
  final String? error;

  const ParkingState({
    required this.parkings,
    required this.loading,
    required this.error,
  });

  factory ParkingState.initial() {
    return const ParkingState(parkings: [], loading: false, error: null);
  }

  ParkingState copyWith({
    List<ParkingModel>? parkings,
    bool? loading,
    String? error,
  }) {
    return ParkingState(
      parkings: parkings ?? this.parkings,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

final parkingProvider =
    StateNotifierProvider<ParkingController, ParkingState>((ref) {
  return ParkingController(ParkingRepository());
});

class ParkingController extends StateNotifier<ParkingState> {
  final ParkingRepository _repo;

  ParkingController(this._repo) : super(ParkingState.initial());

  Future<void> loadAll() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final list = await _repo.getAll();
      state = state.copyWith(loading: false, parkings: list);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }
}

