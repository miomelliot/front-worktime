class WorkdayPlan {
  const WorkdayPlan({
    required this.date,
    required this.plannedStart,
    required this.plannedEnd,
    required this.expectedHours,
    required this.breakMinutes,
    this.isDayOff = false,
    this.isShortened = false,
  });

  final DateTime date;
  final String plannedStart;
  final String plannedEnd;
  final double expectedHours;
  final int breakMinutes;
  final bool isDayOff;
  final bool isShortened;
}
