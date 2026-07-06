import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../features/team/domain/employee_status.dart';
import '../theme/app_spacing.dart';
import 'dashboard_card.dart';
import 'initials_avatar.dart';
import 'role_badge.dart';
import 'status_badge.dart';

class EmployeeStatusTable extends StatelessWidget {
  const EmployeeStatusTable(
      {super.key, required this.employees, required this.onOpen});

  final List<EmployeeStatus> employees;
  final void Function(EmployeeStatus employee) onOpen;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          const _HeaderRow(),
          for (var i = 0; i < employees.length; i++)
            _EmployeeRow(
              employee: employees[i],
              isLast: i == employees.length - 1,
              onTap: () => onOpen(employees[i]),
            ),
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context) {
    final colors = ShadTheme.of(context).colorScheme;
    final style = TextStyle(
      fontSize: 12,
      color: colors.mutedForeground,
      fontWeight: FontWeight.w700,
    );
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text('Сотрудник', style: style)),
          Expanded(flex: 2, child: Text('Отдел', style: style)),
          Expanded(flex: 2, child: Text('Роль', style: style)),
          Expanded(flex: 2, child: Text('Статус', style: style)),
          Expanded(flex: 2, child: Text('Часы', style: style)),
          const SizedBox(width: 32),
        ],
      ),
    );
  }
}

class _EmployeeRow extends StatefulWidget {
  const _EmployeeRow(
      {required this.employee, required this.isLast, required this.onTap});

  final EmployeeStatus employee;
  final bool isLast;
  final VoidCallback onTap;

  @override
  State<_EmployeeRow> createState() => _EmployeeRowState();
}

class _EmployeeRowState extends State<_EmployeeRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = ShadTheme.of(context).colorScheme;
    final employee = widget.employee;
    final user = employee.user;
    final hasHours = employee.plannedHours > 0;
    final progress = hasHours
        ? (employee.actualHours / employee.plannedHours).clamp(0.0, 1.0)
        : 0.0;
    final accent = statusAccent(employee.status);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: _hovered ? colors.muted : null,
            border: widget.isLast
                ? null
                : Border(
                    bottom: BorderSide(
                        color: colors.border.withValues(alpha: 0.6))),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    InitialsAvatar(name: user.name, size: 32),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            user.name,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: colors.foreground,
                            ),
                          ),
                          Text(
                            user.email,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  user.department ?? '—',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.foreground, fontSize: 13),
                ),
              ),
              Expanded(flex: 2, child: RoleBadge(role: user.role)),
              Expanded(flex: 2, child: StatusBadge(status: employee.status)),
              Expanded(
                flex: 2,
                child: hasHours
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${employee.actualHours.toStringAsFixed(1)} / ${employee.plannedHours.toStringAsFixed(1)} ч',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colors.foreground,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: SizedBox(
                              width: 72,
                              height: 5,
                              child: ColoredBox(
                                color: colors.muted,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: FractionallySizedBox(
                                    widthFactor: progress,
                                    child: ColoredBox(color: accent),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Text(
                        '—',
                        style: TextStyle(color: colors.mutedForeground),
                      ),
              ),
              SizedBox(
                width: 32,
                child: Icon(
                  LucideIcons.chevronRight,
                  size: 16,
                  color: colors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
