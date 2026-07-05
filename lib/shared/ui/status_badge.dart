import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../features/today/domain/work_status.dart';
import '../theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final WorkStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = _statusColors(status);
    return ShadBadge.outline(
      backgroundColor: colors.$1,
      foregroundColor: colors.$2,
      child: Text(status.label),
    );
  }
}

/// The solid color [StatusBadge] uses as foreground for [status] — reused
/// wherever a status needs to drive another visual (a progress bar, a
/// timeline dot) so it always agrees with the badge shown next to it.
Color statusAccent(WorkStatus status) => _statusColors(status).$2;

(Color, Color) _statusColors(WorkStatus status) {
  switch (status) {
    case WorkStatus.working:
      return (AppColors.statusWorkingBg, AppColors.statusWorkingText);
    case WorkStatus.paused:
      return (AppColors.statusPausedBg, AppColors.statusPausedText);
    case WorkStatus.notStarted:
      return (AppColors.statusNotStartedBg, AppColors.statusNotStartedText);
    case WorkStatus.stopped:
      return (AppColors.statusStoppedBg, AppColors.statusStoppedText);
    case WorkStatus.dayOff:
      return (AppColors.statusDayOffBg, AppColors.statusDayOffText);
    case WorkStatus.holiday:
      return (AppColors.statusHolidayBg, AppColors.statusHolidayText);
    case WorkStatus.shortened:
      return (AppColors.statusShortenedBg, AppColors.statusShortenedText);
    case WorkStatus.vacationDisplayOnly:
      return (const Color(0xfff3e8ff), AppColors.violet);
    case WorkStatus.sickDisplayOnly:
      return (const Color(0xffffedd5), const Color(0xff9a3412));
  }
}
