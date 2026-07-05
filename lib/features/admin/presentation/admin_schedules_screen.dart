import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../shared/theme/app_spacing.dart';
import '../../../shared/ui/shared_ui.dart';
import '../application/admin_controller.dart';

class AdminSchedulesScreen extends ConsumerWidget {
  const AdminSchedulesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final admin = ref.watch(adminControllerProvider);
    return admin.when(
      loading: () => const LoadingState(label: 'Loading schedules'),
      error: (error, stackTrace) => ErrorState(message: '$error'),
      data: (snapshot) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(
              title: 'Schedules', description: 'Read-only schedule templates.'),
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.lg,
            children: [
              for (final schedule in snapshot.schedules)
                SizedBox(
                  width: 360,
                  child: ShadCard(
                    title: Text(schedule.name),
                    description: Text(schedule.type),
                    child: Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Timezone: ${schedule.timezone}'),
                          Text('Start/stop grace: ${schedule.grace}'),
                          const SizedBox(height: AppSpacing.sm),
                          Text(schedule.summary,
                              style: const TextStyle(color: Color(0xff667085))),
                        ],
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
