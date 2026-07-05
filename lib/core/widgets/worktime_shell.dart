import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/user_profile.dart';

class WorktimeShell extends StatelessWidget {
  const WorktimeShell({
    super.key,
    required this.child,
    required this.user,
  });

  final Widget child;
  final UserProfile user;

  static const _destinations = [
    _ShellDestination(
      path: '/',
      label: 'Главная',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
    ),
    _ShellDestination(
      path: '/time',
      label: 'Таймер',
      icon: Icons.timer_outlined,
      selectedIcon: Icons.timer,
    ),
    _ShellDestination(
      path: '/calendar',
      label: 'Календарь',
      icon: Icons.calendar_month_outlined,
      selectedIcon: Icons.calendar_month,
    ),
    _ShellDestination(
      path: '/organization',
      label: 'Команда',
      icon: Icons.groups_outlined,
      selectedIcon: Icons.groups,
      managerOnly: true,
    ),
    _ShellDestination(
      path: '/admin/users',
      label: 'Администрирование',
      icon: Icons.admin_panel_settings_outlined,
      selectedIcon: Icons.admin_panel_settings,
      adminOnly: true,
    ),
    _ShellDestination(
      path: '/profile',
      label: 'Профиль',
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final visible = _destinations.where((destination) {
      if (destination.adminOnly) return user.isAdmin;
      if (destination.managerOnly) return user.canViewOrgDashboards;
      return true;
    }).toList();
    final location = GoRouterState.of(context).uri.path;
    final selectedIndex = visible.indexWhere(
      (destination) =>
          location == destination.path ||
          (destination.path == '/admin/users' &&
              location.startsWith('/admin')) ||
          (destination.path != '/' && location.startsWith(destination.path)),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;
        if (compact) {
          return Scaffold(
            body: child,
            bottomNavigationBar: NavigationBar(
              selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
              onDestinationSelected: (index) => context.go(visible[index].path),
              destinations: [
                for (final destination in visible)
                  NavigationDestination(
                    icon: Icon(destination.icon),
                    selectedIcon: Icon(destination.selectedIcon),
                    label: destination.label,
                  ),
              ],
            ),
          );
        }

        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                extended: constraints.maxWidth >= 1180,
                selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
                onDestinationSelected: (index) =>
                    context.go(visible[index].path),
                labelType: constraints.maxWidth >= 1180
                    ? NavigationRailLabelType.none
                    : NavigationRailLabelType.all,
                leading: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Icon(Icons.access_time_filled, size: 32),
                ),
                destinations: [
                  for (final destination in visible)
                    NavigationRailDestination(
                      icon: Icon(destination.icon),
                      selectedIcon: Icon(destination.selectedIcon),
                      label: Text(destination.label),
                    ),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(child: child),
            ],
          ),
        );
      },
    );
  }
}

class _ShellDestination {
  const _ShellDestination({
    required this.path,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    this.adminOnly = false,
    this.managerOnly = false,
  });

  final String path;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool adminOnly;
  final bool managerOnly;
}
