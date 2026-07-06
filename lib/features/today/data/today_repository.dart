import '../../../shared/api/api_client.dart';
import '../../../shared/api/time_tracking_helpers.dart';
import '../domain/time_event.dart';
import '../domain/work_status.dart';
import '../domain/workday_plan.dart';

/// Raw session snapshot for [userId]'s work date — kept close to the wire
/// shape (rather than the UI's [WorkSession]) so [TodayController] can pull
/// out `started_at`/`pause_seconds` itself to drive a live-ticking timer.
class TodayRaw {
  const TodayRaw({
    required this.session,
    required this.plan,
    required this.events,
  });

  final Map<String, dynamic>? session;
  final WorkdayPlan plan;
  final List<TimeEvent> events;

  WorkStatus get status =>
      workStatusFromSession(session, isDayOff: plan.isDayOff);
}

/// Numbers for the three stat tiles under the hero timer card.
class TodayStats {
  const TodayStats({
    required this.weeklyWorkedSeconds,
    required this.weeklyExpectedSeconds,
    required this.workDaysThisMonth,
    required this.openViolations,
  });

  final int weeklyWorkedSeconds;
  final int weeklyExpectedSeconds;
  final int workDaysThisMonth;
  final int openViolations;
}

class TodayRepository {
  const TodayRepository(this._client);

  final ApiClient _client;

  Future<TodayRaw> load(String userId) async {
    final today = DateTime.now();
    final results = await Future.wait([
      fetchSession(_client, userId, today),
      _client.get('/users/$userId/workday-plans'),
      _fetchEvents(userId, today),
    ]);

    final session = results[0] as Map<String, dynamic>?;
    final plans = (results[1] as List).cast<Map<String, dynamic>>();
    final eventsJson = results[2] as List<Map<String, dynamic>>;

    final planJson = plans.firstWhereOrNull(
      (p) => sameDate(DateTime.parse(p['work_date'] as String), today),
    );
    final plan = planJson != null
        ? WorkdayPlan.fromJson(planJson)
        : WorkdayPlan(
            date: today,
            plannedStart: '-',
            plannedEnd: '-',
            expectedHours: 0,
            breakMinutes: 0,
            isDayOff: true,
          );

    final events = eventsJson.map(TimeEvent.fromJson).toList()
      ..sort((a, b) => a.time.compareTo(b.time));

    return TodayRaw(session: session, plan: plan, events: events);
  }

  Future<Map<String, dynamic>> start(String userId) => _command('start', userId);
  Future<Map<String, dynamic>> pause(String userId) => _command('pause', userId);
  Future<Map<String, dynamic>> resume(String userId) =>
      _command('resume', userId);
  Future<Map<String, dynamic>> stop(String userId) => _command('stop', userId);

  Future<Map<String, dynamic>> _command(String action, String userId) async {
    final json =
        await _client.post('/time-tracking/$action', body: {'user_id': userId});
    return json as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> _fetchEvents(
      String userId, DateTime date) async {
    final json = await _client.get('/time-tracking/events', query: {
      'user_id': userId,
      'work_date': dateOnly(date),
    });
    return (json as List).cast<Map<String, dynamic>>();
  }

  /// Weekly hours (Monday through today), this month's scheduled working
  /// days, and open violations — three N+1-ish reads (one per day-so-far in
  /// the week, plus plans and violations) since the backend has no
  /// pre-aggregated "my week" endpoint.
  Future<TodayStats> loadStats(String userId) async {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final daysSoFar = [
      for (var i = 0; i < 7; i++) monday.add(Duration(days: i)),
    ].where((d) => !d.isAfter(now)).toList();

    final results = await Future.wait([
      Future.wait(daysSoFar.map((d) => fetchSession(_client, userId, d))),
      _client.get('/users/$userId/workday-plans'),
      _client.get('/users/$userId/violations'),
    ]);

    final weekSessions = results[0] as List<Map<String, dynamic>?>;
    final weeklyWorkedSeconds = weekSessions.fold<int>(
      0,
      (sum, s) => sum + ((s?['worked_seconds'] as num?)?.toInt() ?? 0),
    );

    final plans = (results[1] as List).cast<Map<String, dynamic>>();
    final plansByDate = {
      for (final p in plans) dateOnly(DateTime.parse(p['work_date'] as String)): p,
    };
    final weeklyExpectedSeconds = daysSoFar.fold<int>(0, (sum, d) {
      final plan = plansByDate[dateOnly(d)];
      return sum + ((plan?['expected_seconds'] as num?)?.toInt() ?? 0);
    });
    final workDaysThisMonth = plans.where((p) {
      final date = DateTime.parse(p['work_date'] as String);
      return date.year == now.year &&
          date.month == now.month &&
          (p['is_working'] as bool? ?? true);
    }).length;

    final violations = (results[2] as List).cast<Map<String, dynamic>>();
    final openViolations =
        violations.where((v) => v['status'] == 'open').length;

    return TodayStats(
      weeklyWorkedSeconds: weeklyWorkedSeconds,
      weeklyExpectedSeconds: weeklyExpectedSeconds,
      workDaysThisMonth: workDaysThisMonth,
      openViolations: openViolations,
    );
  }
}
