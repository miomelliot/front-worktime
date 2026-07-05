import 'package:widgetbook/widgetbook.dart';
import 'package:worktime/features/today/domain/work_status.dart';
import 'package:worktime/shared/ui/timer_card.dart';

final timerCardBook = WidgetbookComponent(
  name: 'TimerCard',
  useCases: [
    for (final status in <WorkStatus>[
      WorkStatus.notStarted,
      WorkStatus.working,
      WorkStatus.paused,
      WorkStatus.stopped,
      WorkStatus.dayOff,
    ])
      WidgetbookUseCase.child(
        name: status.label,
        child: TimerCard(
          status: status,
          elapsed: status == WorkStatus.notStarted
              ? Duration.zero
              : const Duration(hours: 4, minutes: 12, seconds: 8),
          onStart: () {},
          onPause: () {},
          onResume: () {},
          onStop: () {},
        ),
      ),
  ],
);
