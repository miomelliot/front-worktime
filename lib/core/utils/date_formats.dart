import 'package:intl/intl.dart';

/// Helpers for the backend's date/datetime conventions.
///
/// Key rules from the API contract:
/// - Request *date* fields are plain `YYYY-MM-DD`.
/// - Request *datetime* fields are RFC3339.
/// - Response `time.Time` is RFC3339/RFC3339Nano.
/// - Logical dates in responses arrive as `YYYY-MM-DDT00:00:00Z`
///   (a date "at midnight"), NOT as a bare `YYYY-MM-DD`.
class ApiDate {
  const ApiDate._();

  static final DateFormat _ymd = DateFormat('yyyy-MM-dd');

  /// Formats a [DateTime] as `YYYY-MM-DD` for request query/body fields.
  ///
  /// Uses the date's calendar components as-is (no timezone shifting), which
  /// matches how the UI reasons about "which day" the user picked.
  static String formatDateOnly(DateTime date) => _ymd.format(date);

  /// Today as `YYYY-MM-DD` in the device's local time — used for e.g. the
  /// current work_date when loading today's session.
  static String todayDateOnly() => _ymd.format(DateTime.now());

  /// Parses a response value that is either a `YYYY-MM-DD` string or the
  /// `YYYY-MM-DDT00:00:00Z` "date at midnight" form the backend emits for
  /// logical dates. Returns `null` for null/empty/unparseable input.
  static DateTime? parseLogicalDate(String? value) {
    if (value == null || value.isEmpty) return null;
    // Accept both bare dates and full RFC3339 timestamps.
    final parsed = DateTime.tryParse(value);
    if (parsed != null) return parsed;
    try {
      return _ymd.parseStrict(value);
    } catch (_) {
      return null;
    }
  }

  /// Parses an RFC3339/RFC3339Nano datetime response field.
  static DateTime? parseDateTime(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  /// Formats a [DateTime] as an RFC3339 string for request datetime fields.
  static String formatRfc3339(DateTime value) =>
      value.toUtc().toIso8601String();
}
