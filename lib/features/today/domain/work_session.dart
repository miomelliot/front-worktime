import 'time_event.dart';
import 'work_status.dart';
import 'workday_plan.dart';

class WorkSession {
  const WorkSession({
    required this.status,
    required this.elapsed,
    required this.plan,
    required this.events,
  });

  final WorkStatus status;
  final Duration elapsed;
  final WorkdayPlan plan;
  final List<TimeEvent> events;

  WorkSession copyWith({
    WorkStatus? status,
    Duration? elapsed,
    WorkdayPlan? plan,
    List<TimeEvent>? events,
  }) {
    return WorkSession(
      status: status ?? this.status,
      elapsed: elapsed ?? this.elapsed,
      plan: plan ?? this.plan,
      events: events ?? this.events,
    );
  }
}
