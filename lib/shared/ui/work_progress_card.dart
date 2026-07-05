import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

class WorkProgressCard extends StatelessWidget {
  const WorkProgressCard({
    super.key,
    required this.worked,
    required this.expected,
    this.title = 'Прогресс дня',
  });

  final Duration worked;
  final Duration expected;
  final String title;

  @override
  Widget build(BuildContext context) {
    final expectedMinutes = expected.inMinutes;
    final percent =
        expectedMinutes == 0 ? 0.0 : worked.inMinutes / expectedMinutes;
    final clamped = percent.clamp(0.0, 1.0);
    final remaining = expected - worked;
    final isOverworked = remaining.isNegative;

    return ShadCard(
      radius: AppRadius.card,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                '${(percent * 100).round()}%',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Container(
              height: 10,
              color: AppColors.surfaceMuted,
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: clamped,
                child: Container(
                  decoration: BoxDecoration(
                    color: isOverworked
                        ? AppColors.statusShortenedText
                        : AppColors.brand,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _ProgressFact(
                  label: 'Отработано',
                  value: _formatDuration(worked),
                ),
              ),
              Expanded(
                child: _ProgressFact(
                  label: 'План',
                  value: _formatDuration(expected),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            expectedMinutes == 0
                ? 'Сегодня рабочее время не запланировано.'
                : isOverworked
                    ? 'Сверх плана: ${_formatDuration(remaining.abs())}.'
                    : 'Осталось: ${_formatDuration(remaining)}.',
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _ProgressFact extends StatelessWidget {
  const _ProgressFact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

String _formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  if (hours == 0) return '$minutesм';
  if (minutes == 0) return '$hoursч';
  return '$hoursч $minutesм';
}
