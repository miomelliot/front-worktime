import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../features/auth/application/auth_controller.dart';
import '../features/auth/domain/user_role.dart';
import '../shared/theme/app_colors.dart';
import '../shared/theme/app_spacing.dart';
import '../shared/ui/role_badge.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider);
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 920;
        final role = user?.role ?? UserRole.employee;
        final nav = _SidebarNav(role: role);
        return ColoredBox(
          color: AppColors.canvas,
          child: Row(
            children: [
              if (wide) SizedBox(width: 264, child: nav),
              Expanded(
                child: Column(
                  children: [
                    const _TopHeader(),
                    if (!wide) _CompactNav(role: role),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1280),
                            child: child,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TopHeader extends ConsumerWidget {
  const _TopHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider);
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      decoration: const BoxDecoration(
        color: Color(0xffffffff),
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          const Spacer(),
          if (user != null) ...[
            RoleBadge(role: user.role),
            const SizedBox(width: AppSpacing.md),
            Text(user.name,
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
          const SizedBox(width: AppSpacing.md),
          ShadButton.ghost(
            leading: const Icon(LucideIcons.logOut, size: 18),
            onPressed: () {
              ref.read(authControllerProvider.notifier).logout();
              context.go('/login');
            },
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
  }
}

class _CompactNav extends StatelessWidget {
  const _CompactNav({required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: const BoxDecoration(
        color: Color(0xffffffff),
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final item in _items(role))
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: Center(
                child: _NavButton(
                  item: item,
                  selected: location == item.path,
                  fill: false,
                  onPressed: () => context.go(item.path),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SidebarNav extends StatelessWidget {
  const _SidebarNav({required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final items = _items(role);
    final location = GoRouterState.of(context).uri.path;
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xffffffff),
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xff111827),
                ),
                child: const Icon(LucideIcons.timer,
                    color: Color(0xffffffff), size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              const Text('Worktime',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          for (final item in items)
            _NavButton(
              item: item,
              selected: location == item.path,
              onPressed: () => context.go(item.path),
            ),
          const Spacer(),
          const Text('MVP-1 · демо-прототип',
              style: TextStyle(fontSize: 12, color: AppColors.muted)),
        ],
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.label, this.path, this.icon);

  final String label;
  final String path;
  final IconData icon;
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onPressed,
    this.fill = true,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onPressed;
  final bool fill;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: ShadButton.raw(
        variant:
            selected ? ShadButtonVariant.secondary : ShadButtonVariant.ghost,
        onPressed: onPressed,
        width: fill ? double.infinity : null,
        mainAxisAlignment: MainAxisAlignment.start,
        leading: Icon(item.icon, size: 18),
        child: Text(item.label),
      ),
    );
  }
}

List<_NavItem> _items(UserRole role) {
  if (role == UserRole.admin) {
    return const [
      _NavItem('Дашборд', '/admin', LucideIcons.layoutDashboard),
      _NavItem('Сотрудники', '/admin/users', LucideIcons.users),
      _NavItem('Отделы', '/admin/departments', LucideIcons.building2),
      _NavItem('Графики', '/admin/schedules', LucideIcons.clock),
      _NavItem('Производственный календарь', '/admin/production-calendar',
          LucideIcons.calendarCog),
      _NavItem('Команда', '/team', LucideIcons.briefcaseBusiness),
      _NavItem('Профиль', '/profile', LucideIcons.user),
    ];
  }
  return const [
    _NavItem('Сегодня', '/today', LucideIcons.timer),
    _NavItem('Календарь', '/calendar', LucideIcons.calendarDays),
    _NavItem('Команда', '/team', LucideIcons.users),
    _NavItem('Профиль', '/profile', LucideIcons.user),
  ];
}
