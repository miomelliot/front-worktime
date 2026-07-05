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

final routerProvider = Provider<GoRouter>((ref) {
  final user = ref.watch(authControllerProvider);
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
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
