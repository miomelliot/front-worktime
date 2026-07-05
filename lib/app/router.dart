import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/domain/auth_state.dart';
import '../features/auth/presentation/auth_controller.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';

/// App router.
///
/// The router reacts to [authControllerProvider] via a [ChangeNotifier] bridge
/// ([_RouterNotifier]) and enforces auth-based access with `redirect`:
///
/// - While [AuthState.unknown] (restoring a session) it shows a splash and
///   holds navigation.
/// - Unauthenticated users are sent to `/login` (and may reach `/register`).
/// - Authenticated users on an auth route are sent to `/` (home).
///
/// Feature routes (time tracking, calendar, org status, admin, ...) are added
/// under the home shell in later iterations. For now `/` is a placeholder.
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const _HomePlaceholderScreen(),
      ),
      GoRoute(
        path: LoginScreen.routePath,
        name: LoginScreen.routeName,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RegisterScreen.routePath,
        name: RegisterScreen.routeName,
        builder: (context, state) => const RegisterScreen(),
      ),
    ],
  );
});

/// Bridges Riverpod's [authControllerProvider] to go_router's
/// [Listenable]-based refresh, and hosts the redirect logic.
class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this._ref) {
    _ref.listen<AuthState>(
      authControllerProvider,
      (_, __) => notifyListeners(),
    );
  }

  final Ref _ref;

  static const _authRoutes = {
    LoginScreen.routePath,
    RegisterScreen.routePath,
  };

  String? redirect(BuildContext context, GoRouterState state) {
    final authState = _ref.read(authControllerProvider);
    final location = state.matchedLocation;
    final onAuthRoute = _authRoutes.contains(location);

    // Still restoring the session: keep showing the splash at `/`.
    if (authState.isUnknown) {
      return location == '/' ? null : '/';
    }

    final isAuthed = authState.isAuthenticated;

    if (!isAuthed) {
      // Unauthenticated users may only be on an auth route.
      return onAuthRoute ? null : LoginScreen.routePath;
    }

    // Authenticated users should not sit on an auth route.
    if (onAuthRoute) return '/';
    return null;
  }
}

/// Temporary landing screen for authenticated users.
///
/// Replaced by the real dashboard shell in a later iteration. Also renders the
/// splash while the session is being restored (AuthState.unknown).
class _HomePlaceholderScreen extends ConsumerWidget {
  const _HomePlaceholderScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    if (authState.isUnknown) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final user = authState.userOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Worktime'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () =>
                ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, size: 48),
              const SizedBox(height: 16),
              Text(
                user == null
                    ? 'Signed in'
                    : 'Signed in as ${user.fullName}',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Feature screens (dashboard, time tracker, calendar, '
                'organization status, profile, admin) are added in the next '
                'iterations.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
