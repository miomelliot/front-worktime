import '../../today/domain/time_event.dart';
import '../../today/domain/workday_plan.dart';

enum CalendarDayType {
  workday,
  weekend,
  holiday,
  shortened,
  dayOff,
  worked,
  underworkedDisplayOnly,
}

extension CalendarDayTypeLabel on CalendarDayType {
  String get label {
    switch (this) {
      case CalendarDayType.workday:
        return 'Workday';
      case CalendarDayType.weekend:
        return 'Weekend';
      case CalendarDayType.holiday:
        return 'Holiday';
      case CalendarDayType.shortened:
        return 'Shortened';
      case CalendarDayType.dayOff:
        return 'Day off';
      case CalendarDayType.worked:
        return 'Worked';
      case CalendarDayType.underworkedDisplayOnly:
        return 'Underworked';
    }
  }
}

class CalendarDay {
  const CalendarDay({
    required this.date,
    required this.type,
    required this.plan,
    required this.events,
    required this.actualHours,
  });

  final DateTime date;
  final CalendarDayType type;
  final WorkdayPlan plan;
  final List<TimeEvent> events;
  final double actualHours;
}
