import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/api/api_client.dart';
import '../../../shared/api/time_tracking_helpers.dart';
import '../../auth/application/auth_controller.dart';
import '../data/today_repository.dart';
import '../domain/time_event.dart';
import '../domain/work_session.dart';
import '../domain/work_status.dart';

final todayRepositoryProvider =
    Provider((ref) => TodayRepository(ref.watch(apiClientProvider)));

final todayControllerProvider =
    AsyncNotifierProvider<TodayController, WorkSession>(TodayController.new);

final todayStatsProvider = FutureProvider<TodayStats>((ref) {
  final userId = ref.watch(authControllerProvider)?.id;
  if (userId == null) {
    return const TodayStats(
      weeklyWorkedSeconds: 0,
      weeklyExpectedSeconds: 0,
      workDaysThisMonth: 0,
      openViolations: 0,
    );
  }
  return ref.read(todayRepositoryProvider).loadStats(userId);
});

class TodayController extends AsyncNotifier<WorkSession> {
  Timer? _ticker;

  @override
  Future<WorkSession> build() async {
    ref.onDispose(() => _ticker?.cancel());
    final session = await _load();
    _rescheduleTicker(session.status);
    return session;
  }

  Future<WorkSession> _load() async {
    // Watched (not read) so logging out/in as someone else on the same
    // device re-runs `build()` instead of leaving the previous user's
    // session cached until an unrelated rebuild happens to occur.
    final userId = ref.watch(authControllerProvider)?.id;
    if (userId == null) {
      throw StateError('Не авторизован');
    }
    final raw = await ref.read(todayRepositoryProvider).load(userId);
    return WorkSession(
      status: raw.status,
      elapsed: elapsedFromSession(raw.session, raw.status == WorkStatus.working),
      plan: raw.plan,
      events: raw.events,
    );
  }

  Future<void> start() => _command((repo, id) => repo.start(id));
  Future<void> pause() => _command((repo, id) => repo.pause(id));
  Future<void> resume() => _command((repo, id) => repo.resume(id));
  Future<void> stop() => _command((repo, id) => repo.stop(id));

  Future<void> _command(
    Future<Map<String, dynamic>> Function(TodayRepository, String) action,
  ) async {
    final current = state.value;
    final userId = ref.read(authControllerProvider)?.id;
    if (current == null || userId == null) return;

    final result = await action(ref.read(todayRepositoryProvider), userId);
    final session = result['session'] as Map<String, dynamic>;
    final event = TimeEvent.fromJson(result['event'] as Map<String, dynamic>);
    final status =
        workStatusFromSession(session, isDayOff: current.plan.isDayOff);

    state = AsyncData(
      current.copyWith(
        status: status,
        elapsed: elapsedFromSession(session, status == WorkStatus.working),
        events: [...current.events, event],
      ),
    );
    _rescheduleTicker(status);
  }

  /// Backend `worked_seconds` only updates at pause/resume/stop, so while
  /// actively working the clock is computed client-side from `started_at`
  /// — this timer just re-renders that computation once a second so the UI
  /// doesn't look frozen. It never re-fetches the session over the network.
  void _rescheduleTicker(WorkStatus status) {
    _ticker?.cancel();
    if (status != WorkStatus.working) return;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final current = state.value;
      if (current == null) return;
      state = AsyncData(
        current.copyWith(elapsed: current.elapsed + const Duration(seconds: 1)),
      );
    });
  }
}
