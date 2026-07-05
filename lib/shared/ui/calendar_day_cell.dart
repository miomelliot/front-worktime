import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../features/calendar/domain/calendar_day.dart';
import '../theme/app_colors.dart';

class CalendarDayCell extends StatelessWidget {
  const CalendarDayCell({
    super.key,
    required this.day,
    this.isSelected = false,
    this.isToday = false,
    this.onTap,
  });

  final CalendarDay day;
  final bool isSelected;
  final bool isToday;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = ShadTheme.of(context).colorScheme;
    final tone = _tone(day.type);
    final subtitle = _subtitle(day);
    final background = isSelected ? AppColors.brand : tone.$1;
    final foreground = isSelected ? colors.background : tone.$2;

    return MouseRegion(
      cursor: onTap == null
          ? MouseCursor.defer
          : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(10),
            border: isToday && !isSelected
                ? Border.all(color: AppColors.brand, width: 1.5)
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${day.date.day}',
                style: TextStyle(
                  color: foreground,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                subtitle,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected
                      ? colors.background.withValues(alpha: 0.85)
                      : colors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _subtitle(CalendarDay day) {
  if (day.type == CalendarDayType.worked ||
      day.type == CalendarDayType.underworkedDisplayOnly) {
    return '${day.type.label} · ${day.actualHours.toStringAsFixed(0)}ч';
  }
  return day.type.label;
}

(Color, Color) _tone(CalendarDayType type) {
  return switch (type) {
    CalendarDayType.workday => (
        const Color(0xffffffff),
        const Color(0xff101828),
      ),
    CalendarDayType.weekend ||
    CalendarDayType.dayOff =>
      (AppColors.statusDayOffBg, AppColors.statusDayOffText),
    CalendarDayType.holiday => (
        AppColors.statusHolidayBg,
        AppColors.statusHolidayText,
      ),
    CalendarDayType.shortened => (
        AppColors.statusShortenedBg,
        AppColors.statusShortenedText,
      ),
    CalendarDayType.worked => (
        AppColors.statusWorkingBg,
        AppColors.statusWorkingText,
      ),
    CalendarDayType.underworkedDisplayOnly => (
        AppColors.statusPausedBg,
        AppColors.statusPausedText,
      ),
  };
}
