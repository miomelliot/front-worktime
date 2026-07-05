import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:worktime/shared/theme/app_theme.dart';

import 'components/calendar_day_cell_book.dart';
import 'components/employee_status_card_book.dart';
import 'components/metric_card_book.dart';
import 'components/status_badge_book.dart';
import 'components/timer_card_book.dart';
import 'components/work_progress_card_book.dart';
import 'components/workday_plan_card_book.dart';

void main() {
  runApp(const WorktimeWidgetbook());
}

class WorktimeWidgetbook extends StatelessWidget {
  const WorktimeWidgetbook({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook(
      appBuilder: (context, child) => ShadApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: Padding(padding: const EdgeInsets.all(24), child: child),
      ),
      directories: [
        WidgetbookCategory(
          name: 'Shared UI',
          children: [
            statusBadgeBook,
            roleBadgeBook,
            timerCardBook,
            metricCardBook,
            workdayPlanCardBook,
            workProgressCardBook,
            employeeStatusCardBook,
            calendarDayCellBook,
          ],
        ),
      ],
    );
  }
}
