import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/theme/app_spacing.dart';
import '../../../shared/ui/shared_ui.dart';
import '../../team/application/team_controller.dart';

class AdminUsersScreen extends ConsumerWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final team = ref.watch(teamControllerProvider);
    return team.when(
      loading: () => const LoadingState(label: 'Loading users'),
      error: (error, stackTrace) => ErrorState(message: '$error'),
      data: (state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(
              title: 'Users', description: 'Read-only mock user directory.'),
          EmployeeStatusTable(
            employees: state.employees,
            onOpen: (employee) => context.go('/team/${employee.user.id}'),
          ),
          const SizedBox(height: AppSpacing.lg),
          const EmptyState(
              title: 'CRUD disabled',
              message:
                  'User management actions are intentionally out of scope for MVP-1.'),
        ],
      ),
    );
  }
}
