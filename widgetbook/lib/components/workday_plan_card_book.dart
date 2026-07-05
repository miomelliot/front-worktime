import 'package:widgetbook/widgetbook.dart';
import 'package:worktime/shared/mock/mock_workday.dart';
import 'package:worktime/shared/ui/workday_plan_card.dart';

final workdayPlanCardBook = WidgetbookComponent(
  name: 'WorkdayPlanCard',
  useCases: [
    WidgetbookUseCase.child(
        name: 'обычный день', child: WorkdayPlanCard(plan: standardPlan())),
    WidgetbookUseCase.child(
        name: 'сокращенный день',
        child: WorkdayPlanCard(plan: shortenedPlan())),
    WidgetbookUseCase.child(
        name: 'выходной', child: WorkdayPlanCard(plan: dayOffPlan())),
    WidgetbookUseCase.child(
        name: 'праздник', child: WorkdayPlanCard(plan: holidayPlan())),
  ],
);
