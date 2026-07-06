import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/api/api_client.dart';
import '../data/auth_repository.dart';
import '../domain/app_user.dart';

final authRepositoryProvider =
    Provider((ref) => AuthRepository(ref.watch(apiClientProvider)));

final authControllerProvider =
    NotifierProvider<AuthController, AppUser?>(AuthController.new);

class AuthController extends Notifier<AppUser?> {
  @override
  AppUser? build() {
    // The backend has no refresh token — any 401 means the session is dead,
    // so wire it straight to logout regardless of which screen triggered it.
    ref.read(apiClientProvider).onUnauthorized = logout;
    return null;
  }

  Future<void> login({required String email, required String password}) async {
    final session = await ref
        .read(authRepositoryProvider)
        .login(email: email, password: password);
    ref.read(apiClientProvider).setToken(session.accessToken);
    state = session.user;
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final session = await ref.read(authRepositoryProvider).register(
          email: email,
          password: password,
          fullName: fullName,
        );
    ref.read(apiClientProvider).setToken(session.accessToken);
    state = session.user;
  }

  void setUser(AppUser user) => state = user;

  void logout() {
    ref.read(apiClientProvider).setToken(null);
    state = null;
  }
}
