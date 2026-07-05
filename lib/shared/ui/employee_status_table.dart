import 'package:flutter/widgets.dart';

import '../../features/team/domain/employee_status.dart';
import '../theme/app_spacing.dart';
import 'role_badge.dart';
import 'status_badge.dart';

class EmployeeStatusTable extends StatelessWidget {
  const EmployeeStatusTable(
      {super.key, required this.employees, required this.onOpen});

  final List<EmployeeStatus> employees;
  final void Function(EmployeeStatus employee) onOpen;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xffffffff),
        border: Border.all(color: const Color(0xffd9dee8)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const _HeaderRow(),
          for (final employee in employees)
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => onOpen(employee),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 3,
                          child: Text(employee.user.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600))),
                      Expanded(flex: 2, child: Text(employee.user.department)),
                      Expanded(
                          flex: 2, child: RoleBadge(role: employee.user.role)),
                      Expanded(
                          flex: 2, child: StatusBadge(status: employee.status)),
                      Expanded(
                          child: Text(employee.actualHours.toStringAsFixed(1))),
                    ],
                  ),
                ),
              ),
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
    const style = TextStyle(
        fontSize: 12, color: Color(0xff667085), fontWeight: FontWeight.w700);
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xffd9dee8)))),
      child: const Row(
        children: [
          Expanded(flex: 3, child: Text('Name', style: style)),
          Expanded(flex: 2, child: Text('Department', style: style)),
          Expanded(flex: 2, child: Text('Role', style: style)),
          Expanded(flex: 2, child: Text('Status', style: style)),
          Expanded(child: Text('Hours', style: style)),
        ],
      ),
    );
  }
}
