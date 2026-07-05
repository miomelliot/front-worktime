import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/domain/auth_state.dart';
import '../features/auth/domain/user_profile.dart';
import '../features/auth/presentation/auth_controller.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/worktime/presentation/worktime_screens.dart';
import '../core/widgets/worktime_shell.dart';

/// Основной роутер приложения.
///
/// Реагирует на [authControllerProvider] через мост [ChangeNotifier]
/// ([_RouterNotifier]) и применяет доступ по авторизации через `redirect`:
///
/// - пока [AuthState.unknown] восстанавливает сессию, оставляет пользователя
///   на splash-экране;
/// - неавторизованных пользователей отправляет на `/login`;
/// - авторизованных пользователей уводит с auth-экранов на `/`.
///
/// Маршруты фич добавляются отдельными итерациями под домашнюю оболочку.
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          final authState = ref.watch(authControllerProvider);
          if (authState.isUnknown || authState.userOrNull == null) {
            return const _SplashScreen();
          }
          return WorktimeShell(
            user: authState.userOrNull!,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/time',
            name: 'time',
            builder: (context, state) => const TimeTrackerScreen(),
          ),
          GoRoute(
            path: '/calendar',
            name: 'calendar',
            builder: (context, state) => const CalendarScreen(),
          ),
          GoRoute(
            path: '/organization',
            name: 'organization',
            builder: (context, state) => const OrganizationStatusScreen(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/admin',
            redirect: (context, state) => '/admin/users',
          ),
          GoRoute(
            path: '/admin/users',
            name: 'admin-users',
            builder: (context, state) => const AdminUsersScreen(),
          ),
          GoRoute(
            path: '/admin/departments',
            name: 'admin-departments',
            builder: (context, state) => const AdminDepartmentsScreen(),
          ),
          GoRoute(
            path: '/admin/schedules',
            name: 'admin-schedules',
            builder: (context, state) => const AdminSchedulesScreen(),
          ),
          GoRoute(
            path: '/admin/absences',
            name: 'admin-absences',
            builder: (context, state) => const AdminAbsencesScreen(),
          ),
          GoRoute(
            path: '/admin/corrections',
            name: 'admin-corrections',
            builder: (context, state) => const AdminCorrectionsScreen(),
          ),
        ],
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

/// Связывает [authControllerProvider] с [Listenable]-обновлением go_router.
class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this._ref) {
    _ref.listen<AuthState>(
      authControllerProvider,
      (_, __) => notifyListeners(),
    );
  }

  final Ref _ref;

  /// Маршруты, доступные без bearer-токена.
  static const _authRoutes = {
    LoginScreen.routePath,
    RegisterScreen.routePath,
  };

  /// Возвращает целевой маршрут для auth-редиректа или `null`.
  String? redirect(BuildContext context, GoRouterState state) {
    final authState = _ref.read(authControllerProvider);
    final location = state.uri.path;
    final onAuthRoute = _authRoutes.contains(location);

    // Пока сессия восстанавливается, держим пользователя на `/`.
    if (authState.isUnknown) {
      return location == '/' ? null : '/';
    }

    final isAuthed = authState.isAuthenticated;

    if (!isAuthed) {
      // Неавторизованный пользователь может быть только на auth-маршруте.
      return onAuthRoute ? null : LoginScreen.routePath;
    }

    // Авторизованный пользователь не должен оставаться на auth-маршруте.
    if (onAuthRoute) return '/';

    final user = authState.userOrNull;
    if (location.startsWith('/admin') && user?.isAdmin != true) {
      return '/';
    }
    if (location == '/organization' && user?.canViewOrgDashboards != true) {
      return '/';
    }
    return null;
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
