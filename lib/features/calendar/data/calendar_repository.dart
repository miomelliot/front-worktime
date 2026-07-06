import '../../../shared/api/api_client.dart';
import '../../../shared/api/time_tracking_helpers.dart';
import '../../today/domain/time_event.dart';
import '../../today/domain/workday_plan.dart';
import '../domain/calendar_day.dart';

class CalendarRepository {
  const CalendarRepository(this._client);

  final ApiClient _client;

  /// One month of [CalendarDay]s. `events` is left empty on every entry —
  /// only the selected day's events are ever shown, so [loadEvents] fetches
  /// those lazily on selection instead of pulling all ~30 days' events
  /// upfront.
  Future<List<CalendarDay>> loadMonth(String userId, DateTime month) async {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final dates = [
      for (var d = 1; d <= daysInMonth; d++) DateTime(month.year, month.month, d),
    ];
    final today = DateTime.now();
    final pastOrToday = dates.where((d) => !d.isAfter(today)).toList();

    final results = await Future.wait([
      _client.get('/users/$userId/workday-plans'),
      Future.wait(pastOrToday.map((d) => fetchSession(_client, userId, d))),
    ]);

    final plans = (results[0] as List).cast<Map<String, dynamic>>();
    final plansByDate = {
      for (final p in plans) dateOnly(DateTime.parse(p['work_date'] as String)): p,
    };
    final sessions = results[1] as List<Map<String, dynamic>?>;
    final sessionsByDate = {
      for (var i = 0; i < pastOrToday.length; i++)
        dateOnly(pastOrToday[i]): sessions[i],
    };

    return [
      for (final date in dates)
        _buildDay(
          date,
          plansByDate[dateOnly(date)],
          sessionsByDate[dateOnly(date)],
          today,
        ),
    ];
  }

  Future<List<TimeEvent>> loadEvents(String userId, DateTime date) async {
    final json = await _client.get('/time-tracking/events', query: {
      'user_id': userId,
      'work_date': dateOnly(date),
    });
    final events = (json as List)
        .cast<Map<String, dynamic>>()
        .map(TimeEvent.fromJson)
        .toList();
    events.sort((a, b) => a.time.compareTo(b.time));
    return events;
  }

  CalendarDay _buildDay(
    DateTime date,
    Map<String, dynamic>? planJson,
    Map<String, dynamic>? session,
    DateTime today,
  ) {
    final isWeekend =
        date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
    final plan = planJson != null
        ? WorkdayPlan.fromJson(planJson)
        : WorkdayPlan(
            date: date,
            plannedStart: '-',
            plannedEnd: '-',
            expectedHours: 0,
            breakMinutes: 0,
            isDayOff: true,
          );
    final workedSeconds = (session?['worked_seconds'] as num?)?.toInt() ?? 0;
    final actualHours = workedSeconds / 3600.0;
    final isPastOrToday = !date.isAfter(today);

    final CalendarDayType type;
    if (plan.isDayOff) {
      type = isWeekend ? CalendarDayType.weekend : CalendarDayType.dayOff;
    } else if (!isPastOrToday) {
      type = CalendarDayType.workday;
    } else if (workedSeconds > 0) {
      // A little slack under the expected hours still counts as "worked" —
      // only meaningfully short days get flagged as underworked.
      type = actualHours >= plan.expectedHours - 0.25
          ? CalendarDayType.worked
          : CalendarDayType.underworkedDisplayOnly;
    } else {
      type = CalendarDayType.workday;
    }

    return CalendarDay(
      date: date,
      type: type,
      plan: plan,
      events: const [],
      actualHours: actualHours,
    );
  }
}
