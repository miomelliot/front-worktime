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
        return 'Рабочий';
      case CalendarDayType.weekend:
        return 'Выходной';
      case CalendarDayType.holiday:
        return 'Праздник';
      case CalendarDayType.shortened:
        return 'Сокращ.';
      case CalendarDayType.dayOff:
        return 'Отгул';
      case CalendarDayType.worked:
        return 'Отработан';
      case CalendarDayType.underworkedDisplayOnly:
        return 'Недобор';
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
