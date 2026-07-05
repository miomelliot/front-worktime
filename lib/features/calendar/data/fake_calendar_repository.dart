import '../../../shared/mock/mock_calendar.dart';
import '../domain/calendar_day.dart';

class FakeCalendarRepository {
  Future<List<CalendarDay>> loadMonth(DateTime month) async {
    await Future<void>.delayed(const Duration(milliseconds: 160));
    return buildMockCalendarDays(month);
  }
}
