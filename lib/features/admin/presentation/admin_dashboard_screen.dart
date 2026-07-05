import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../shared/theme/app_spacing.dart';
import '../../../shared/ui/shared_ui.dart';
import '../application/admin_controller.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final admin = ref.watch(adminControllerProvider);
    return admin.when(
      loading: () => const LoadingState(label: 'Loading admin dashboard'),
      error: (error, stackTrace) => ErrorState(message: '$error'),
      data: (snapshot) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(
              title: 'Admin Dashboard',
              description: 'Organization overview from mock data.'),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth > 900
                  ? (constraints.maxWidth - AppSpacing.lg * 3) / 4
                  : 280.0;
              return Wrap(
                spacing: AppSpacing.lg,
                runSpacing: AppSpacing.lg,
                children: [
                  SizedBox(
                      width: width,
                      child: MetricCard(
                          label: 'Total users',
                          value: '${snapshot.totalUsers}',
                          caption: 'Seeded accounts',
                          icon: LucideIcons.users)),
                  SizedBox(
                      width: width,
                      child: MetricCard(
                          label: 'Working now',
                          value: '${snapshot.workingNow}',
                          caption: 'Active sessions',
                          icon: LucideIcons.timer)),
                  SizedBox(
                      width: width,
                      child: MetricCard(
                          label: 'Departments',
                          value: '${snapshot.departments}',
                          caption: 'Org units',
                          icon: LucideIcons.building2)),
                  SizedBox(
                      width: width,
                      child: MetricCard(
                          label: 'Schedules',
                          value: '${snapshot.activeSchedules}',
                          caption: 'Active templates',
                          icon: LucideIcons.clock)),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          const TimeEventTimeline(events: []),
        ],
      ),
    );
  }
}
