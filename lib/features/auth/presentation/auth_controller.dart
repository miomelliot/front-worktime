import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/dio/dio_client.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/errors/error_mapper.dart';
import '../data/auth_repository.dart';
import '../domain/auth_state.dart';

/// Owns the app-wide [AuthState].
///
/// Responsibilities:
/// - On construction, register the 401 handler with the Dio layer and kick off
///   session restore from the stored token.
/// - Expose `login`, `register`, and `logout` actions used by the auth screens.
/// - Drop to [AuthState.unauthenticated] when the token is missing/rejected.
///
/// State transitions here drive the router's redirects (the router listens to
/// this provider).
class AuthController extends Notifier<AuthState> {
  AuthRepository get _repo => ref.read(authRepositoryProvider);

  @override
  AuthState build() {
    // Wire the interceptor's 401 callback to force a local logout. This is set
    // lazily to avoid a provider dependency cycle with the Dio client.
    ref.read(dioUnauthorizedHandlerProvider.notifier).state = () async {
      // The interceptor already cleared the token; just reflect it in state.
      state = const AuthState.unauthenticated(
        message: 'Your session has expired. Please sign in again.',
      );
    };

    // Begin in `unknown` and restore asynchronously.
    Future.microtask(_restore);
    return const AuthState.unknown();
  }

  Future<void> _restore() async {
    try {
      final user = await _repo.restore();
      if (user == null) {
        state = const AuthState.unauthenticated();
      } else {
        state = AuthState.authenticated(user);
      }
    } on Object catch (e) {
      final err = ErrorMapper.map(e);
      // On 401 the interceptor already cleared the token; any restore failure
      // means we cannot present an authenticated session.
      state = AuthState.unauthenticated(
        message: err.isUnauthorized ? null : err.message,
      );
    }
  }

  /// Attempts login. On failure, rethrows a normalized [AppError] so the
  /// screen can show it inline (state itself is left unchanged on failure).
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _repo.login(email: email, password: password);
      state = AuthState.authenticated(res.user);
    } on Object catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  /// Attempts registration + immediate sign-in (backend returns a token).
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    String? timezone,
  }) async {
    try {
      final res = await _repo.register(
        email: email,
        password: password,
        fullName: fullName,
        timezone: timezone,
      );
      state = AuthState.authenticated(res.user);
    } on Object catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  /// Local logout — clears the stored token and resets state. There is no
  /// server logout endpoint.
  Future<void> logout() async {
    await _repo.clearSession();
    state = const AuthState.unauthenticated();
  }

  /// Re-fetches the current profile (e.g. after a profile update). Silently
  /// keeps existing state on failure.
  Future<void> refresh() async {
    try {
      final user = await _repo.refreshMe();
      state = AuthState.authenticated(user);
    } on Object {
      // Ignore; existing state remains valid enough for the UI.
    }
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);
