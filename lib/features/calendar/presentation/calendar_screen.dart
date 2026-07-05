import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/ui/shared_ui.dart';
import '../application/calendar_controller.dart';
import '../domain/calendar_day.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendar = ref.watch(calendarControllerProvider);
    return calendar.when(
      loading: () => const LoadingState(label: 'Загружаем календарь'),
      error: (error, stackTrace) => ErrorState(message: '$error'),
      data: (state) {
        final controller = ref.read(calendarControllerProvider.notifier);
        return LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 980;
            final grid = _CalendarCard(
              state: state,
              onPrevMonth: () => controller.focusMonth(
                DateTime(state.focusedMonth.year, state.focusedMonth.month - 1),
              ),
              onNextMonth: () => controller.focusMonth(
                DateTime(state.focusedMonth.year, state.focusedMonth.month + 1),
              ),
              onToday: controller.goToToday,
              onSelectDay: controller.selectDay,
            );
            final details = _DayDetails(day: state.selected, days: state.days);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PageHeader(
                  title: 'Календарь',
                  description: 'План и факт рабочих дней по месяцам.',
                ),
                if (!wide)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      grid,
                      const SizedBox(height: AppSpacing.xl),
                      details,
                    ],
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 7, child: grid),
                      const SizedBox(width: AppSpacing.xl),
                      Expanded(flex: 5, child: details),
                    ],
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class _CalendarCard extends StatelessWidget {
  const _CalendarCard({
    required this.state,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.onToday,
    required this.onSelectDay,
  });

  final CalendarState state;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onToday;
  final ValueChanged<DateTime> onSelectDay;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _CalendarHeader(
            month: state.focusedMonth,
            onPrevMonth: onPrevMonth,
            onNextMonth: onNextMonth,
            onToday: onToday,
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: _MonthGrid(state: state, onSelectDay: onSelectDay),
          ),
        ],
      ),
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader({
    required this.month,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.onToday,
  });

  final DateTime month;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onToday;

  @override
  Widget build(BuildContext context) {
    final colors = ShadTheme.of(context).colorScheme;
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: Row(
        children: [
          const IconChip(icon: LucideIcons.calendarDays, accent: AppColors.brand, size: 28),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              _formatMonthYear(month),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: colors.foreground,
              ),
            ),
          ),
          ShadButton.ghost(
            size: ShadButtonSize.sm,
            onPressed: onToday,
            child: const Text('Сегодня'),
          ),
          const SizedBox(width: AppSpacing.sm),
          ShadIconButton.outline(
            icon: const Icon(LucideIcons.chevronLeft, size: 16),
            onPressed: onPrevMonth,
          ),
          const SizedBox(width: AppSpacing.xs),
          ShadIconButton.outline(
            icon: const Icon(LucideIcons.chevronRight, size: 16),
            onPressed: onNextMonth,
          ),
        ],
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({required this.state, required this.onSelectDay});

  final CalendarState state;
  final ValueChanged<DateTime> onSelectDay;

  static const _weekdayLabels = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

  @override
  Widget build(BuildContext context) {
    final colors = ShadTheme.of(context).colorScheme;
    final month = state.focusedMonth;
    final firstOfMonth = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leadingBlanks = firstOfMonth.weekday - 1;
    final totalCells = leadingBlanks + daysInMonth;
    final trailingBlanks = (7 - totalCells % 7) % 7;
    final cells = <DateTime?>[
      for (var i = 0; i < leadingBlanks; i++) null,
      for (var day = 1; day <= daysInMonth; day++)
        DateTime(month.year, month.month, day),
      for (var i = 0; i < trailingBlanks; i++) null,
    ];
    final today = DateTime.now();

    return Column(
      children: [
        Row(
          children: [
            for (final label in _weekdayLabels)
              Expanded(
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colors.mutedForeground,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        for (var week = 0; week * 7 < cells.length; week++) ...[
          if (week > 0) const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 76,
            child: Row(
              children: [
                for (var i = week * 7; i < week * 7 + 7; i++) ...[
                  if (i > week * 7) const SizedBox(width: AppSpacing.sm),
                  Expanded(child: _cell(cells[i], today)),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _cell(DateTime? date, DateTime today) {
    if (date == null) return const SizedBox.shrink();
    final match = state.days.where((d) => _sameDate(d.date, date)).firstOrNull;
    if (match == null) return const SizedBox.shrink();
    return CalendarDayCell(
      day: match,
      isSelected: _sameDate(date, state.selectedDay),
      isToday: _sameDate(date, today),
      onTap: () => onSelectDay(date),
    );
  }
}

class _DayDetails extends StatelessWidget {
  const _DayDetails({required this.day, required this.days});

  final CalendarDay? day;
  final List<CalendarDay> days;

  @override
  Widget build(BuildContext context) {
    if (day == null) {
      return const EmptyState(
        title: 'День не выбран',
        message: 'Выберите день в календаре, чтобы увидеть план и события.',
      );
    }
    final worked =
        days.where((item) => item.type == CalendarDayType.worked).length;
    return Column(
      children: [
        WorkdayPlanCard(plan: day!.plan),
        const SizedBox(height: AppSpacing.lg),
        MetricCard(
          icon: LucideIcons.calendarCheck,
          label: 'Итог месяца',
          value: '$worked дн.',
          caption: 'Отработано в этом месяце',
        ),
        const SizedBox(height: AppSpacing.lg),
        TimeEventTimeline(events: day!.events),
      ],
    );
  }
}

String _formatMonthYear(DateTime date) {
  const months = [
    'Январь',
    'Февраль',
    'Март',
    'Апрель',
    'Май',
    'Июнь',
    'Июль',
    'Август',
    'Сентябрь',
    'Октябрь',
    'Ноябрь',
    'Декабрь',
  ];
  return '${months[date.month - 1]} ${date.year}';
}

bool _sameDate(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
