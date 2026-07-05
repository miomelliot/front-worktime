import 'package:flutter/widgets.dart';

import '../../features/calendar/domain/calendar_day.dart';

class CalendarDayCell extends StatelessWidget {
  const CalendarDayCell({
    super.key,
    required this.day,
    this.isSelected = false,
  });

  final CalendarDay day;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final colors = _colors(day.type);
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xff2563eb) : colors.$1,
        borderRadius: BorderRadius.circular(8),
        border:
            Border.all(color: isSelected ? const Color(0xff2563eb) : colors.$2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${day.date.day}',
            style: TextStyle(
              color: isSelected
                  ? const Color(0xffffffff)
                  : const Color(0xff111827),
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Text(
            day.type.label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              color: isSelected
                  ? const Color(0xffffffff)
                  : const Color(0xff667085),
            ),
          ),
        ],
      ),
    );
  }
}

(Color, Color) _colors(CalendarDayType type) {
  switch (type) {
    case CalendarDayType.workday:
      return (const Color(0xffffffff), const Color(0xffe5e7eb));
    case CalendarDayType.weekend:
      return (const Color(0xfff8fafc), const Color(0xffe2e8f0));
    case CalendarDayType.holiday:
      return (const Color(0xffffe4e6), const Color(0xfffecdd3));
    case CalendarDayType.shortened:
      return (const Color(0xffccfbf1), const Color(0xff99f6e4));
    case CalendarDayType.dayOff:
      return (const Color(0xfff1f5f9), const Color(0xffcbd5e1));
    case CalendarDayType.worked:
      return (const Color(0xffdcfce7), const Color(0xffbbf7d0));
    case CalendarDayType.underworkedDisplayOnly:
      return (const Color(0xfffef3c7), const Color(0xfffde68a));
  }
}
