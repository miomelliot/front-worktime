import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:table_calendar/table_calendar.dart';

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
      loading: () => const LoadingState(label: 'Loading calendar'),
      error: (error, stackTrace) => ErrorState(message: '$error'),
      data: (state) {
        final selected = state.selected;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(
                title: 'Calendar',
                description: 'Monthly plan, actual time, and day details.'),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth > 960;
                final calendarCard = ShadCard(
                  child: TableCalendar<CalendarDay>(
                    firstDay: DateTime(DateTime.now().year, 1),
                    lastDay: DateTime(DateTime.now().year, 12, 31),
                    focusedDay: state.focusedMonth,
                    selectedDayPredicate: (day) =>
                        _sameDate(day, state.selectedDay),
                    onDaySelected: (selectedDay, focusedDay) {
                      ref
                          .read(calendarControllerProvider.notifier)
                          .selectDay(selectedDay);
                    },
                    onPageChanged: (focusedDay) {
                      ref
                          .read(calendarControllerProvider.notifier)
                          .focusMonth(focusedDay);
                    },
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) =>
                          _cell(state, day, false),
                      todayBuilder: (context, day, focusedDay) =>
                          _cell(state, day, _sameDate(day, state.selectedDay)),
                      selectedBuilder: (context, day, focusedDay) =>
                          _cell(state, day, true),
                    ),
                    headerStyle: const HeaderStyle(
                        formatButtonVisible: false, titleCentered: true),
                    rowHeight: 82,
                  ),
                );
                final details = _DayDetails(day: selected, days: state.days);
                if (!wide) {
                  return Column(children: [
                    calendarCard,
                    const SizedBox(height: AppSpacing.lg),
                    details
                  ]);
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: calendarCard),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(child: details),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget? _cell(CalendarState state, DateTime day, bool selected) {
    final match =
        state.days.where((item) => _sameDate(item.date, day)).firstOrNull;
    if (match == null) return null;
    return CalendarDayCell(day: match, isSelected: selected);
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
          title: 'No day selected', message: 'Pick a day to inspect its plan.');
    }
    final worked =
        days.where((item) => item.type == CalendarDayType.worked).length;
    return Column(
      children: [
        WorkdayPlanCard(plan: day!.plan),
        const SizedBox(height: AppSpacing.lg),
        MetricCard(
            label: 'Month summary',
            value: '$worked days',
            caption: 'Worked days in mock data'),
        const SizedBox(height: AppSpacing.lg),
        TimeEventTimeline(events: day!.events),
      ],
    );
  }
}

bool _sameDate(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
