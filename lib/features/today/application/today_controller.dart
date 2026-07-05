import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/fake_today_repository.dart';
import '../domain/time_event.dart';
import '../domain/work_session.dart';
import '../domain/work_status.dart';

final fakeTodayRepositoryProvider = Provider((ref) => FakeTodayRepository());

final todayControllerProvider =
    AsyncNotifierProvider<TodayController, WorkSession>(TodayController.new);

class TodayController extends AsyncNotifier<WorkSession> {
  @override
  Future<WorkSession> build() =>
      ref.read(fakeTodayRepositoryProvider).loadToday();

  void start() =>
      _transition(WorkStatus.working, 'start', 'Рабочий день начат');
  void pause() => _transition(WorkStatus.paused, 'pause', 'Пауза в работе');
  void resume() =>
      _transition(WorkStatus.working, 'resume', 'Работа возобновлена');
  void stop() =>
      _transition(WorkStatus.stopped, 'stop', 'Рабочий день завершен');

  void _transition(WorkStatus status, String action, String note) {
    final current = state.value;
    if (current == null) return;
    final elapsed = switch (status) {
      WorkStatus.working => current.elapsed + const Duration(minutes: 1),
      WorkStatus.stopped => const Duration(hours: 8),
      _ => current.elapsed,
    };
    state = AsyncData(
      current.copyWith(
        status: status,
        elapsed: elapsed,
        events: [
          ...current.events,
          TimeEvent(action: action, time: DateTime.now(), note: note),
        ],
      ),
    );
  }
}
