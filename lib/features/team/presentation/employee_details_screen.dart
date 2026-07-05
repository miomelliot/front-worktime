import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/mock/mock_workday.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/ui/shared_ui.dart';
import '../../today/domain/work_status.dart';
import '../application/team_controller.dart';

class EmployeeDetailsScreen extends ConsumerWidget {
  const EmployeeDetailsScreen({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final team = ref.watch(teamControllerProvider);
    return team.when(
      loading: () => const LoadingState(label: 'Loading employee'),
      error: (error, stackTrace) => ErrorState(message: '$error'),
      data: (state) {
        final employee =
            state.employees.where((item) => item.user.id == userId).firstOrNull;
        if (employee == null) {
          return const EmptyState(
              title: 'Employee not found',
              message: 'The mock employee list has no matching user.');
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
                title: employee.user.name,
                description:
                    '${employee.user.title} · ${employee.user.department}'),
            LayoutBuilder(
              builder: (context, constraints) {
                final cards = [
                  EmployeeStatusCard(employee: employee),
                  WorkdayPlanCard(
                      plan: employee.status == WorkStatus.dayOff
                          ? dayOffPlan(DateTime.now())
                          : standardPlan(DateTime.now())),
                  MetricCard(
                      label: 'Mini summary',
                      value: '${employee.actualHours.toStringAsFixed(1)}h',
                      caption: 'Tracked today'),
                  const EmptyState(title: 'Absences', message: 'Coming later'),
                  const EmptyState(
                      title: 'Violations', message: 'Coming later'),
                  const EmptyState(
                      title: 'Corrections', message: 'Coming later'),
                ];
                return Wrap(
                  spacing: AppSpacing.lg,
                  runSpacing: AppSpacing.lg,
                  children: [
                    for (final card in cards)
                      SizedBox(
                          width: constraints.maxWidth > 780
                              ? 360
                              : double.infinity,
                          child: card)
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
