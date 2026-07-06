class WorkdayPlan {
  const WorkdayPlan({
    required this.date,
    required this.plannedStart,
    required this.plannedEnd,
    required this.expectedHours,
    required this.breakMinutes,
    this.isDayOff = false,
    this.isShortened = false,
    this.isHoliday = false,
  });

  final DateTime date;
  final String plannedStart;
  final String plannedEnd;
  final double expectedHours;
  final int breakMinutes;
  final bool isDayOff;
  final bool isShortened;
  final bool isHoliday;

  /// Parses a `GET /users/{id}/workday-plans` entry. `planned_start_at` /
  /// `planned_end_at` are full ISO timestamps in the employee's schedule
  /// offset — sliced directly for "HH:mm" rather than converted through
  /// [DateTime], which would reinterpret them in the viewer's own timezone.
  factory WorkdayPlan.fromJson(Map<String, dynamic> json) {
    final isWorking = json['is_working'] as bool? ?? true;
    return WorkdayPlan(
      date: DateTime.parse(json['work_date'] as String),
      plannedStart: _hhmm(json['planned_start_at'] as String?),
      plannedEnd: _hhmm(json['planned_end_at'] as String?),
      expectedHours: ((json['expected_seconds'] as num?) ?? 0) / 3600.0,
      breakMinutes: (((json['break_seconds'] as num?) ?? 0) / 60).round(),
      isDayOff: !isWorking,
    );
  }
}

String _hhmm(String? iso) {
  if (iso == null || iso.length < 16) return '-';
  return iso.substring(11, 16);
}
