import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../features/team/domain/employee_status.dart';
import '../theme/app_spacing.dart';
import 'initials_avatar.dart';
import 'role_badge.dart';
import 'status_badge.dart';

class EmployeeStatusCard extends StatelessWidget {
  const EmployeeStatusCard({super.key, required this.employee, this.onOpen});

  final EmployeeStatus employee;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final colors = ShadTheme.of(context).colorScheme;
    final user = employee.user;
    final hasHours = employee.plannedHours > 0;
    final progress = hasHours
        ? (employee.actualHours / employee.plannedHours).clamp(0.0, 1.0)
        : 0.0;
    final accent = statusAccent(employee.status);

    return ShadCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InitialsAvatar(name: user.name),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: colors.foreground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.email,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 12, color: colors.mutedForeground),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              StatusBadge(status: employee.status),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              RoleBadge(role: user.role),
              ShadBadge.outline(child: Text(user.department)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (hasHours) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: Container(
                height: 6,
                color: colors.muted,
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(color: accent),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${employee.actualHours.toStringAsFixed(1)} из ${employee.plannedHours.toStringAsFixed(1)} ч',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colors.foreground,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
          Row(
            children: [
              Icon(LucideIcons.history, size: 13, color: colors.mutedForeground),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  employee.lastEvent,
                  overflow: TextOverflow.ellipsis,
                  style:
                      TextStyle(fontSize: 12, color: colors.mutedForeground),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: ShadButton.outline(
              onPressed: onOpen,
              trailing: const Icon(LucideIcons.chevronRight, size: 14),
              child: const Text('Открыть профиль'),
            ),
          ),
        ],
      ),
    );
  }
}
