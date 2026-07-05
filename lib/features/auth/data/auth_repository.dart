import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/token_storage.dart';
import '../domain/auth_response.dart';
import '../domain/user_profile.dart';
import 'auth_api.dart';

/// Coordinates the auth API with token storage.
///
/// The repository owns the "session material" side effects: after a successful
/// login/register it persists the access token; on logout it clears storage.
/// The controller drives app state and calls into this repository.
class AuthRepository {
  AuthRepository({
    required AuthApi api,
    required TokenStorage storage,
  })  : _api = api,
        _storage = storage;

  final AuthApi _api;
  final TokenStorage _storage;

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _api.login(email: email, password: password);
    await _persist(response);
    return response;
  }

  Future<AuthResponse> register({
    required String email,
    required String password,
    required String fullName,
    String? timezone,
  }) async {
    final response = await _api.register(
      email: email,
      password: password,
      fullName: fullName,
      timezone: timezone,
    );
    await _persist(response);
    return response;
  }

  /// Restores the current user from a stored token. Returns `null` when there
  /// is no stored token; throws (mapped upstream) if the token is rejected.
  Future<UserProfile?> restore() async {
    final token = await _storage.readAccessToken();
    if (token == null || token.isEmpty) return null;
    // A 401 here is handled by the AuthInterceptor (clears token) and surfaces
    // as an error the controller treats as "unauthenticated".
    return _api.getMe();
  }

  Future<UserProfile> refreshMe() => _api.getMe();

  /// Local logout — no server endpoint exists, so we simply drop the token.
  Future<void> clearSession() => _storage.clear();

  bool get hasStoredExpiry => true;

  Future<void> _persist(AuthResponse response) {
    return _storage.saveToken(
      accessToken: response.accessToken,
      expiresAt: response.expiresAt,
    );
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    api: ref.watch(authApiProvider),
    storage: ref.watch(tokenStorageProvider),
  );
});
