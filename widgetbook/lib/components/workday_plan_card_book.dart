import 'package:widgetbook/widgetbook.dart';
import 'package:worktime/shared/mock/mock_workday.dart';
import 'package:worktime/shared/ui/workday_plan_card.dart';

final workdayPlanCardBook = WidgetbookComponent(
  name: 'WorkdayPlanCard',
  useCases: [
    WidgetbookUseCase.child(
        name: 'normal workday', child: WorkdayPlanCard(plan: standardPlan())),
    WidgetbookUseCase.child(
        name: 'shortened workday',
        child: WorkdayPlanCard(plan: shortenedPlan())),
    WidgetbookUseCase.child(
        name: 'day off', child: WorkdayPlanCard(plan: dayOffPlan())),
  ],
);
