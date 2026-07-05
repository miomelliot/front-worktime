import 'package:widgetbook/widgetbook.dart';
import 'package:worktime/features/calendar/domain/calendar_day.dart';
import 'package:worktime/shared/mock/mock_calendar.dart';
import 'package:worktime/shared/ui/calendar_day_cell.dart';

final calendarDayCellBook = WidgetbookComponent(
  name: 'CalendarDayCell',
  useCases: [
    for (final type in CalendarDayType.values
        .where((type) => type != CalendarDayType.dayOff))
      WidgetbookUseCase.child(
        name: type.label,
        child: CalendarDayCell(
          day: buildMockCalendarDays(DateTime.now())
              .firstWhere((day) => day.type == type),
        ),
      ),
  ],
);
