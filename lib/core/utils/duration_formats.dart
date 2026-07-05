/// Helpers for the backend's duration conventions.
///
/// Two very different encodings appear in the contract:
///
/// 1. `*_seconds` fields (e.g. `worked_seconds`, `pause_seconds`,
///    `expected_seconds`, `break_seconds`) — plain integer **seconds**.
///
/// 2. Go `time.Duration` fields serialized as JSON — integer **nanoseconds**,
///    because `time.Duration` is an `int64`. This affects `start_time`,
///    `end_time`, `time_from`, and `time_to`. These represent a time-of-day
///    offset (nanoseconds since midnight) on schedule/absence records.
class ApiDuration {
  const ApiDuration._();

  static const int _nanosPerSecond = 1000000000;

  /// Converts a nanosecond `time.Duration` value (as sent by Go JSON) into
  /// whole seconds. Returns `null` for null input.
  static int? nanosToSeconds(int? nanos) =>
      nanos == null ? null : nanos ~/ _nanosPerSecond;

  /// Converts whole seconds into nanoseconds — used when a request needs to
  /// echo a `time.Duration`-typed field (rare; most requests use `*_seconds`).
  static int secondsToNanos(int seconds) => seconds * _nanosPerSecond;

  /// Formats a count of seconds as `H:MM:SS` (hours are not zero-padded).
  static String formatHms(int totalSeconds) {
    final negative = totalSeconds < 0;
    var s = totalSeconds.abs();
    final h = s ~/ 3600;
    s %= 3600;
    final m = s ~/ 60;
    final sec = s % 60;
    final buf = '${negative ? '-' : ''}$h:'
        '${m.toString().padLeft(2, '0')}:'
        '${sec.toString().padLeft(2, '0')}';
    return buf;
  }

  /// Formats a count of seconds compactly, e.g. `8h 30m` or `45m`.
  static String formatHm(int totalSeconds) {
    final negative = totalSeconds < 0;
    final s = totalSeconds.abs();
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    final sign = negative ? '-' : '';
    if (h == 0) return '$sign${m}m';
    if (m == 0) return '$sign${h}h';
    return '$sign${h}h ${m}m';
  }

  /// Formats a nanoseconds-since-midnight offset (a `time.Duration` time-of-day
  /// field) as `HH:MM`. Returns `null` for null input.
  static String? formatTimeOfDayFromNanos(int? nanos) {
    if (nanos == null) return null;
    final totalSeconds = nanos ~/ _nanosPerSecond;
    final h = (totalSeconds ~/ 3600) % 24;
    final m = (totalSeconds % 3600) ~/ 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }
}
