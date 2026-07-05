import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_radius.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/ui/shared_ui.dart';
import '../application/today_controller.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayControllerProvider);
    return today.when(
      loading: () => const LoadingState(label: 'Загружаем день'),
      error: (error, stackTrace) => ErrorState(message: '$error'),
      data: (session) {
        final controller = ref.read(todayControllerProvider.notifier);
        final expected = Duration(
          minutes: (session.plan.expectedHours * 60).round(),
        );
        final remaining = expected - session.elapsed;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Сегодня',
              description:
                  '${_formatRussianDate(DateTime.now())} · рабочее пространство сотрудника',
            ),
            const SizedBox(height: AppSpacing.sm),
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
                    WorkProgressCard(
                      worked: session.elapsed,
                      expected: expected,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _TodaySummaryCard(
                        worked: session.elapsed,
                        remaining: remaining,
                        breakMinutes: session.plan.breakMinutes,
                        eventsCount: session.events.length,
                      ),
                    ),
                  ],
                );
                if (!wide) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      timer,
                      const SizedBox(height: AppSpacing.lg),
                      side,
                    ],
                  );
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

class _TodaySummaryCard extends StatelessWidget {
  const _TodaySummaryCard({
    required this.worked,
    required this.remaining,
    required this.breakMinutes,
    required this.eventsCount,
  });

  final Duration worked;
  final Duration remaining;
  final int breakMinutes;
  final int eventsCount;

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      radius: AppRadius.card,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Сводка',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          LayoutBuilder(
            builder: (context, constraints) {
              final twoColumns = constraints.maxWidth >= 320;
              final width = twoColumns
                  ? (constraints.maxWidth - AppSpacing.md) / 2
                  : constraints.maxWidth;
              return Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: [
                  _SummaryMetric(
                    width: width,
                    icon: LucideIcons.timer,
                    label: 'Отработано',
                    value: _formatShort(worked),
                  ),
                  _SummaryMetric(
                    width: width,
                    icon: LucideIcons.hourglass,
                    label: 'Осталось',
                    value: remaining.isNegative
                        ? '+${_formatShort(remaining.abs())}'
                        : _formatShort(remaining),
                  ),
                  _SummaryMetric(
                    width: width,
                    icon: LucideIcons.coffee,
                    label: 'Перерыв',
                    value: '$breakMinutesм',
                  ),
                  _SummaryMetric(
                    width: width,
                    icon: LucideIcons.listChecks,
                    label: 'События',
                    value: '$eventsCount',
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

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.width,
    required this.icon,
    required this.label,
    required this.value,
  });

  final double width;
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: AppColors.brand),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatRussianDate(DateTime date) {
  const weekdays = [
    'понедельник',
    'вторник',
    'среда',
    'четверг',
    'пятница',
    'суббота',
    'воскресенье',
  ];
  const months = [
    'января',
    'февраля',
    'марта',
    'апреля',
    'мая',
    'июня',
    'июля',
    'августа',
    'сентября',
    'октября',
    'ноября',
    'декабря',
  ];
  final weekday = weekdays[date.weekday - 1];
  final month = months[date.month - 1];
  return '$weekday, ${date.day} $month';
}

String _formatShort(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  if (hours == 0) return '$minutesм';
  if (minutes == 0) return '$hoursч';
  return '$hoursч $minutesм';
}
