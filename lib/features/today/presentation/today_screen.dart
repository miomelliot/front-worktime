import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../shared/theme/app_spacing.dart';
import '../../../shared/ui/shared_ui.dart';
import '../application/today_controller.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayControllerProvider);
    return today.when(
      loading: () => const LoadingState(label: 'Loading today'),
      error: (error, stackTrace) => ErrorState(message: '$error'),
      data: (session) {
        final controller = ref.read(todayControllerProvider.notifier);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Today',
              description: DateFormat.yMMMMEEEEd().format(DateTime.now()),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth > 880;
                final timer = TimerCard(
                  status: session.status,
                  elapsed: session.elapsed,
                  onStart: controller.start,
                  onPause: controller.pause,
                  onResume: controller.resume,
                  onStop: controller.stop,
                );
                final side = Column(
                  children: [
                    WorkdayPlanCard(plan: session.plan),
                    const SizedBox(height: AppSpacing.lg),
                    MetricCard(
                      label: 'Today summary',
                      value:
                          '${session.elapsed.inHours}h ${session.elapsed.inMinutes.remainder(60)}m',
                      caption: '${session.events.length} events recorded',
                      icon: LucideIcons.listChecks,
                    ),
                  ],
                );
                if (!wide) {
                  return Column(children: [
                    timer,
                    const SizedBox(height: AppSpacing.lg),
                    side
                  ]);
                }
                return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: timer),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(child: side),
                    ]);
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            TimeEventTimeline(events: session.events),
          ],
        );
      },
    );
  }
}
