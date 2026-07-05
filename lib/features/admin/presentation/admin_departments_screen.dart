import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../shared/theme/app_spacing.dart';
import '../../../shared/ui/shared_ui.dart';
import '../../team/application/team_controller.dart';

class AdminDepartmentsScreen extends ConsumerWidget {
  const AdminDepartmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final team = ref.watch(teamControllerProvider);
    return team.when(
      loading: () => const LoadingState(label: 'Loading departments'),
      error: (error, stackTrace) => ErrorState(message: '$error'),
      data: (state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(
              title: 'Departments',
              description: 'Read-only department structure.'),
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.lg,
            children: [
              for (final department in state.departments)
                SizedBox(
                  width: 310,
                  child: ShadCard(
                    title: Text(department.name),
                    description: Text('Manager: ${department.managerName}'),
                    child: Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.lg),
                      child: MetricCard(
                        label: 'Employees',
                        value: '${department.employeeCount}',
                        caption: 'Mock headcount',
                        icon: LucideIcons.users,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
