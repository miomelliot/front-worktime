import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/admin/presentation/admin_dashboard_screen.dart';
import '../features/admin/presentation/admin_departments_screen.dart';
import '../features/admin/presentation/admin_production_calendar_screen.dart';
import '../features/admin/presentation/admin_schedules_screen.dart';
import '../features/admin/presentation/admin_users_screen.dart';
import '../features/auth/application/auth_controller.dart';
import '../features/auth/domain/user_role.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/calendar/presentation/calendar_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/team/presentation/employee_details_screen.dart';
import '../features/team/presentation/team_screen.dart';
import '../features/today/presentation/today_screen.dart';
import 'app_shell.dart';

/// Notifies GoRouter to re-run [GoRouter.redirect] whenever the auth state
/// changes, without recreating the router itself. [routerProvider] used to
/// `ref.watch(authControllerProvider)` directly, which rebuilt a brand new
/// `GoRouter` (resetting it to `initialLocation`) on *any* auth-state
/// change — including saving your own profile, which bounced you from
/// `/profile` back to `/today` since the fresh router re-evaluates
/// `redirect` against `/login`.
class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable(Ref ref) {
    ref.listen(authControllerProvider, (_, __) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authRefresh = _AuthRefreshListenable(ref);
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: authRefresh,
    redirect: (context, state) {
      final user = ref.read(authControllerProvider);
      final isLogin = state.matchedLocation == '/login';
      if (user == null) return isLogin ? null : '/login';
      if (isLogin) return user.role == UserRole.admin ? '/admin' : '/today';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
              path: '/today', builder: (context, state) => const TodayScreen()),
          GoRoute(
              path: '/calendar',
              builder: (context, state) => const CalendarScreen()),
          GoRoute(
              path: '/team', builder: (context, state) => const TeamScreen()),
          GoRoute(
            path: '/team/:userId',
            builder: (context, state) =>
                EmployeeDetailsScreen(userId: state.pathParameters['userId']!),
          ),
          GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen()),
          GoRoute(
              path: '/admin',
              builder: (context, state) => const AdminDashboardScreen()),
          GoRoute(
              path: '/admin/users',
              builder: (context, state) => const AdminUsersScreen()),
          GoRoute(
              path: '/admin/departments',
              builder: (context, state) => const AdminDepartmentsScreen()),
          GoRoute(
              path: '/admin/schedules',
              builder: (context, state) => const AdminSchedulesScreen()),
          GoRoute(
            path: '/admin/production-calendar',
            builder: (context, state) => const AdminProductionCalendarScreen(),
          ),
        ],
      ),
    ],
  );
});
