import '../../features/calendar/domain/calendar_day.dart';
import '../../features/today/domain/time_event.dart';
import 'mock_workday.dart';

List<CalendarDay> buildMockCalendarDays(DateTime anchor) {
  final daysInMonth = DateTime(anchor.year, anchor.month + 1, 0).day;
  return List.generate(daysInMonth, (index) {
    final date = DateTime(anchor.year, anchor.month, index + 1);
    final weekend =
        date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
    CalendarDayType type;
    if (index == 6) {
      type = CalendarDayType.holiday;
    } else if (index == 12) {
      type = CalendarDayType.shortened;
    } else if (index == 18) {
      type = CalendarDayType.underworkedDisplayOnly;
    } else if (weekend) {
      type = CalendarDayType.weekend;
    } else if (date.isBefore(DateTime.now())) {
      type = CalendarDayType.worked;
    } else {
      type = CalendarDayType.workday;
    }
    final plan = switch (type) {
      CalendarDayType.holiday ||
      CalendarDayType.weekend ||
      CalendarDayType.dayOff =>
        dayOffPlan(date),
      CalendarDayType.shortened => shortenedPlan(date),
      _ => standardPlan(date),
    };
    return CalendarDay(
      date: date,
      type: type,
      plan: plan,
      events: type == CalendarDayType.worked ||
              type == CalendarDayType.underworkedDisplayOnly
          ? <TimeEvent>[...mockEvents]
          : const <TimeEvent>[],
      actualHours: type == CalendarDayType.underworkedDisplayOnly
          ? 5.5
          : (type == CalendarDayType.worked ? 8 : 0),
    );
  });
}
