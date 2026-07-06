import 'api_client.dart';

/// Shared helpers for talking to the time-tracking/workday-plan endpoints —
/// used by both the Today and Team features so date formatting and the
/// "no session yet" (404) handling stay consistent.

String dateOnly(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

bool sameDate(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Slices "HH:mm" directly out of an ISO timestamp rather than converting
/// through [DateTime], which would reinterpret it in the viewer's timezone
/// instead of the schedule's own offset.
String hhmm(String iso) => iso.length >= 16 ? iso.substring(11, 16) : iso;

/// `GET /time-tracking/session` for [userId]/[workDate] — null on the
/// backend's 404 (no session started that day yet), not an error.
Future<Map<String, dynamic>?> fetchSession(
  ApiClient client,
  String userId,
  DateTime workDate,
) async {
  try {
    final json = await client.get('/time-tracking/session', query: {
      'user_id': userId,
      'work_date': dateOnly(workDate),
    });
    return json as Map<String, dynamic>;
  } on ApiException catch (e) {
    if (e.isNotFound) return null;
    rethrow;
  }
}

/// Live elapsed time for a session. `worked_seconds` on the backend is only
/// recalculated at pause/resume/stop — while [status] is `working` it stays
/// stale at whatever it was when the shift last resumed, so elapsed must be
/// computed from `started_at` instead of trusted directly.
Duration elapsedFromSession(Map<String, dynamic>? session, bool isWorking) {
  if (session == null) return Duration.zero;
  if (isWorking) {
    final startedAtRaw = session['started_at'] as String?;
    if (startedAtRaw == null) return Duration.zero;
    final startedAt = DateTime.parse(startedAtRaw);
    final pauseSeconds = (session['pause_seconds'] as num?)?.toInt() ?? 0;
    final elapsed =
        DateTime.now().toUtc().difference(startedAt.toUtc()) -
            Duration(seconds: pauseSeconds);
    return elapsed.isNegative ? Duration.zero : elapsed;
  }
  final workedSeconds = (session['worked_seconds'] as num?)?.toInt() ?? 0;
  return Duration(seconds: workedSeconds);
}

extension FirstWhereOrNull<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
