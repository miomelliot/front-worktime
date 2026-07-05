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

(Color, Color) _statusColors(WorkStatus status) {
  switch (status) {
    case WorkStatus.working:
      return (const Color(0xffdcfce7), const Color(0xff166534));
    case WorkStatus.paused:
      return (const Color(0xfffef3c7), AppColors.amber);
    case WorkStatus.notStarted:
      return (const Color(0xffeef2ff), AppColors.violet);
    case WorkStatus.stopped:
      return (const Color(0xffe0f2fe), const Color(0xff075985));
    case WorkStatus.dayOff:
      return (const Color(0xfff1f5f9), const Color(0xff475569));
    case WorkStatus.holiday:
      return (const Color(0xffffe4e6), AppColors.rose);
    case WorkStatus.shortened:
      return (const Color(0xffccfbf1), AppColors.teal);
    case WorkStatus.vacationDisplayOnly:
      return (const Color(0xfff3e8ff), AppColors.violet);
    case WorkStatus.sickDisplayOnly:
      return (const Color(0xffffedd5), const Color(0xff9a3412));
  }
}
