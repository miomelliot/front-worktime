import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../shared/theme/app_spacing.dart';
import '../../../shared/ui/shared_ui.dart';
import '../application/team_controller.dart';

class TeamScreen extends ConsumerWidget {
  const TeamScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final team = ref.watch(teamControllerProvider);
    return team.when(
      loading: () => const LoadingState(label: 'Loading team'),
      error: (error, stackTrace) => ErrorState(message: '$error'),
      data: (state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(
              title: 'Team',
              description: 'Who is working now across departments.'),
          _Filters(state: state, ref: ref),
          const SizedBox(height: AppSpacing.lg),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 860) {
                return EmployeeStatusTable(
                  employees: state.filtered,
                  onOpen: (employee) => context.go('/team/${employee.user.id}'),
                );
              }
              return Wrap(
                spacing: AppSpacing.lg,
                runSpacing: AppSpacing.lg,
                children: [
                  for (final employee in state.filtered)
                    SizedBox(
                      width: 360,
                      child: EmployeeStatusCard(
                        employee: employee,
                        onOpen: () => context.go('/team/${employee.user.id}'),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({required this.state, required this.ref});

  final TeamState state;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(teamControllerProvider.notifier);
    final departments = [
      'All',
      ...state.departments.map((department) => department.name)
    ];
    const statuses = ['All', 'Working', 'Paused', 'Stopped', 'Day off'];
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        SizedBox(
          width: 280,
          child: ShadInput(
            placeholder: const Text('Search name or email'),
            onChanged: controller.setQuery,
          ),
        ),
        _ChipSelect(
            values: departments,
            current: state.department,
            onChanged: controller.setDepartment),
        _ChipSelect(
            values: statuses,
            current: state.status,
            onChanged: controller.setStatus),
      ],
    );
  }
}

class _ChipSelect extends StatelessWidget {
  const _ChipSelect(
      {required this.values, required this.current, required this.onChanged});

  final List<String> values;
  final String current;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      children: [
        for (final value in values)
          ShadButton.raw(
            variant: value == current
                ? ShadButtonVariant.secondary
                : ShadButtonVariant.outline,
            size: ShadButtonSize.sm,
            onPressed: () => onChanged(value),
            child: Text(value),
          ),
      ],
    );
  }
}
