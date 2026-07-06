import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/api/api_client.dart';
import '../../../shared/api/token_storage.dart';
import '../../admin/application/admin_controller.dart';
import '../../calendar/application/calendar_controller.dart';
import '../../profile/application/profile_controller.dart';
import '../../team/application/team_controller.dart';
import '../../today/application/today_controller.dart';
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

    // Restore a cached session synchronously (no loading flash, no flicker
    // through the login screen) then quietly confirm it's still valid —
    // an expired/revoked token gets caught by onUnauthorized above.
    final cached = TokenStorage.load();
    if (cached == null) return null;
    ref.read(apiClientProvider).setToken(cached.token);
    _revalidateInBackground();
    return cached.user;
  }

  Future<void> _revalidateInBackground() async {
    try {
      final user = await ref.read(authRepositoryProvider).me();
      state = user;
      final token = ref.read(apiClientProvider).token;
      if (token != null) TokenStorage.save(token, user);
    } on ApiException {
      // A 401 already triggered logout() via onUnauthorized; anything else
      // isn't actionable here — keep the optimistic cached session.
    } catch (_) {
      // Network hiccup on startup — same, keep the cached session.
    }
  }

  Future<void> login({required String email, required String password}) async {
    final session = await ref
        .read(authRepositoryProvider)
        .login(email: email, password: password);
    _applySession(session.accessToken, session.user);
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
    _applySession(session.accessToken, session.user);
  }

  void setUser(AppUser user) {
    state = user;
    final token = ref.read(apiClientProvider).token;
    if (token != null) TokenStorage.save(token, user);
  }

  void logout() {
    ref.read(apiClientProvider).setToken(null);
    TokenStorage.clear();
    state = null;

    // Every other controller caches data fetched for whoever was logged in
    // (team roster, today's session, calendar, profile) and most only
    // `ref.read` the actor once in their own `build()`, so they wouldn't
    // otherwise refetch for the next person to log in on this device.
    ref.invalidate(teamControllerProvider);
    ref.invalidate(todayControllerProvider);
    ref.invalidate(calendarControllerProvider);
    ref.invalidate(profileControllerProvider);
    ref.invalidate(adminControllerProvider);
  }

  void _applySession(String token, AppUser user) {
    ref.read(apiClientProvider).setToken(token);
    TokenStorage.save(token, user);
    state = user;
  }
}
