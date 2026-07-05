import 'package:widgetbook/widgetbook.dart';
import 'package:worktime/shared/ui/work_progress_card.dart';

final workProgressCardBook = WidgetbookComponent(
  name: 'WorkProgressCard',
  useCases: [
    WidgetbookUseCase.child(
      name: '0%',
      child: const WorkProgressCard(
        worked: Duration.zero,
        expected: Duration(hours: 8),
      ),
    ),
    WidgetbookUseCase.child(
      name: '45%',
      child: const WorkProgressCard(
        worked: Duration(hours: 3, minutes: 36),
        expected: Duration(hours: 8),
      ),
    ),
    WidgetbookUseCase.child(
      name: '100%',
      child: const WorkProgressCard(
        worked: Duration(hours: 8),
        expected: Duration(hours: 8),
      ),
    ),
    WidgetbookUseCase.child(
      name: 'переработка',
      child: const WorkProgressCard(
        worked: Duration(hours: 9, minutes: 20),
        expected: Duration(hours: 8),
      ),
    ),
  ],
);
