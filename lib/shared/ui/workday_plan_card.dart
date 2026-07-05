import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../features/today/domain/workday_plan.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

class WorkdayPlanCard extends StatelessWidget {
  const WorkdayPlanCard({super.key, required this.plan});

  final WorkdayPlan plan;

  @override
  Widget build(BuildContext context) {
    final tone = _planTone(plan);
    return ShadCard(
      radius: AppRadius.card,
      title: const Text('План дня'),
      description: Text(_description(plan)),
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: tone.$1,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(tone.$3, size: 18, color: tone.$2),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      _planLabel(plan),
                      style: TextStyle(
                        color: tone.$2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.xl,
              runSpacing: AppSpacing.lg,
              children: [
                _PlanFact(label: 'Старт', value: plan.plannedStart),
                _PlanFact(label: 'Финиш', value: plan.plannedEnd),
                _PlanFact(
                  label: 'План',
                  value: '${plan.expectedHours.toStringAsFixed(1)}ч',
                ),
                _PlanFact(label: 'Перерыв', value: '${plan.breakMinutes}м'),
              ],
            ),
            if (!plan.isDayOff) ...[
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'Допуск на старт/стоп: 10 минут. Данные пока тестовые.',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PlanFact extends StatelessWidget {
  const _PlanFact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(height: AppSpacing.xs),
          Text(value,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

String _description(WorkdayPlan plan) {
  if (plan.isHoliday) return 'Праздничный день без рабочих часов';
  if (plan.isDayOff) return 'Сегодня работа не запланирована';
  if (plan.isShortened) return 'Сокращенный график и перерыв';
  return 'Ожидаемый график и перерыв';
}

String _planLabel(WorkdayPlan plan) {
  if (plan.isHoliday) return 'Праздник';
  if (plan.isDayOff) return 'Выходной';
  if (plan.isShortened) return 'Сокращенный день';
  return 'Обычный рабочий день';
}

(Color, Color, IconData) _planTone(WorkdayPlan plan) {
  if (plan.isHoliday) {
    return (
      AppColors.statusHolidayBg,
      AppColors.statusHolidayText,
      LucideIcons.partyPopper
    );
  }
  if (plan.isDayOff) {
    return (
      AppColors.statusDayOffBg,
      AppColors.statusDayOffText,
      LucideIcons.calendarOff
    );
  }
  if (plan.isShortened) {
    return (
      AppColors.statusShortenedBg,
      AppColors.statusShortenedText,
      LucideIcons.clock3
    );
  }
  return (
    AppColors.statusWorkingBg,
    AppColors.statusWorkingText,
    LucideIcons.calendarCheck
  );
}
