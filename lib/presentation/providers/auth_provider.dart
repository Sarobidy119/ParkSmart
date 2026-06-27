import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/repositories/auth_repository.dart';

class AuthState {
  final User? user;
  final bool loading;
  final String? error;

  const AuthState({
    required this.user,
    required this.loading,
    required this.error,
  });

  factory AuthState.initial() {
    return const AuthState(user: null, loading: false, error: null);
  }

  AuthState copyWith({
    User? user,
    bool? loading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

final authProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(AuthRepository());
});

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthController(this._repo) : super(AuthState.initial()) {
    _loadCurrent();
  }

  Future<void> _loadCurrent() async {
    final user = _repo.getCurrentUser();
    state = state.copyWith(user: user);
  }

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(loading: true, error: null);
    try {
      await _repo.signIn(email: email, password: password);
      state = state.copyWith(loading: false, user: _repo.getCurrentUser());
    } catch (e) {
      final message = e is AuthMessageException ? e.message : formatAuthError(e);
      state = state.copyWith(loading: false, error: message);
      throw AuthMessageException(message);
    }
  }

  Future<void> signUp({
    required String nom,
    required String prenom,
    required String email,
    required String telephone,
    required String password,
  }) async {
    state = state.copyWith(loading: true, error: null);
    try {
      await _repo.signUp(
        nom: nom,
        prenom: prenom,
        email: email,
        telephone: telephone,
        password: password,
      );
      state = state.copyWith(loading: false, user: _repo.getCurrentUser());
    } catch (e) {
      final message = e is AuthMessageException ? e.message : formatAuthError(e);
      state = state.copyWith(loading: false, error: message);
      throw AuthMessageException(message);
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(loading: true, error: null);
    try {
      await _repo.signOut();
      state = state.copyWith(loading: false, user: null);
    } catch (e) {
      final message = e is AuthMessageException ? e.message : formatAuthError(e);
      state = state.copyWith(loading: false, error: message);
      throw AuthMessageException(message);
    }
  }
}
