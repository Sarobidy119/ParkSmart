import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectivityState {
  final bool isConnected;
  final ConnectivityResult connectionType;

  const ConnectivityState({
    required this.isConnected,
    required this.connectionType,
  });

  factory ConnectivityState.initial() {
    return const ConnectivityState(
      isConnected: true,
      connectionType: ConnectivityResult.none,
    );
  }

  ConnectivityState copyWith({
    bool? isConnected,
    ConnectivityResult? connectionType,
  }) {
    return ConnectivityState(
      isConnected: isConnected ?? this.isConnected,
      connectionType: connectionType ?? this.connectionType,
    );
  }
}

final connectivityProvider =
    StateNotifierProvider<ConnectivityController, ConnectivityState>((ref) {
  return ConnectivityController();
});

class ConnectivityController extends StateNotifier<ConnectivityState> {
  final Connectivity _connectivity = Connectivity();

  ConnectivityController() : super(ConnectivityState.initial()) {
    _initConnectivity();
    _listenConnectivity();
  }

  Future<void> _initConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      // La nouvelle version retourne une List<ConnectivityResult>
      final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
      _updateConnectivity(result);
    } catch (e) {
      state = state.copyWith(isConnected: false);
    }
  }

  void _listenConnectivity() {
    _connectivity.onConnectivityChanged.listen((results) {
      // La nouvelle version retourne une List<ConnectivityResult>
      final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
      _updateConnectivity(result);
    });
  }

  void _updateConnectivity(ConnectivityResult result) {
    final isConnected = result != ConnectivityResult.none;
    state = ConnectivityState(
      isConnected: isConnected,
      connectionType: result,
    );
  }

  bool get isOnline => state.isConnected;
}
