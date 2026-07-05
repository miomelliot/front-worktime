import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../features/team/domain/employee_status.dart';
import '../theme/app_spacing.dart';
import 'role_badge.dart';
import 'status_badge.dart';

class EmployeeStatusCard extends StatelessWidget {
  const EmployeeStatusCard({super.key, required this.employee, this.onOpen});

  final EmployeeStatus employee;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Avatar(name: employee.user.name),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(employee.user.name,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(employee.user.email,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xff667085))),
                  ],
                ),
              ),
              StatusBadge(status: employee.status),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          RoleBadge(role: employee.user.role),
          const SizedBox(height: AppSpacing.md),
          Text(employee.user.department),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${employee.actualHours.toStringAsFixed(1)} / ${employee.plannedHours.toStringAsFixed(1)}h · ${employee.lastEvent}',
            style: const TextStyle(color: Color(0xff667085)),
          ),
          const SizedBox(height: AppSpacing.md),
          ShadButton.outline(
              onPressed: onOpen, child: const Text('Open details')),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xffeef2ff),
      ),
      child: Text(
        name.split(' ').map((part) => part[0]).take(2).join(),
        style: const TextStyle(
            fontWeight: FontWeight.w800, color: Color(0xff4338ca)),
      ),
    );
  }
}
