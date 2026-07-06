import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../features/team/domain/employee_status.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import 'initials_avatar.dart';
import 'status_badge.dart';

/// A compact rectangle for one employee — avatar, name and a status badge.
/// Used in a [Wrap] grouped by department so a whole team fits at a glance
/// without a table.
class EmployeeStatusTile extends StatefulWidget {
  const EmployeeStatusTile({super.key, required this.employee, this.onTap});

  final EmployeeStatus employee;
  final VoidCallback? onTap;

  @override
  State<EmployeeStatusTile> createState() => _EmployeeStatusTileState();
}

class _EmployeeStatusTileState extends State<EmployeeStatusTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = ShadTheme.of(context).colorScheme;
    final user = widget.employee.user;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: _hovered ? colors.muted : colors.background,
            borderRadius: AppRadius.card,
            border: Border.all(
              color: _hovered
                  ? colors.foreground.withValues(alpha: 0.16)
                  : colors.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  InitialsAvatar(name: user.name, size: 32),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      user.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: colors.foreground,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              StatusBadge(status: widget.employee.status),
            ],
          ),
        ),
      ),
    );
  }
}
