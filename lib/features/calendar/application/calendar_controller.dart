import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/api/api_client.dart';
import '../../auth/application/auth_controller.dart';
import '../data/calendar_repository.dart';
import '../domain/calendar_day.dart';

class CalendarState {
  const CalendarState({
    required this.focusedMonth,
    required this.selectedDay,
    required this.days,
  });

  final DateTime focusedMonth;
  final DateTime selectedDay;
  final List<CalendarDay> days;

  CalendarDay? get selected {
    for (final day in days) {
      if (_sameDate(day.date, selectedDay)) return day;
    }
    return null;
  }

  CalendarState copyWith({
    DateTime? focusedMonth,
    DateTime? selectedDay,
    List<CalendarDay>? days,
  }) {
    return CalendarState(
      focusedMonth: focusedMonth ?? this.focusedMonth,
      selectedDay: selectedDay ?? this.selectedDay,
      days: days ?? this.days,
    );
  }
}

final calendarRepositoryProvider =
    Provider((ref) => CalendarRepository(ref.watch(apiClientProvider)));

final calendarControllerProvider =
    AsyncNotifierProvider<CalendarController, CalendarState>(
        CalendarController.new);

class CalendarController extends AsyncNotifier<CalendarState> {
  @override
  Future<CalendarState> build() async {
    final now = DateTime.now();
    final days = await _loadMonth(now);
    final state = CalendarState(focusedMonth: now, selectedDay: now, days: days);
    return _withEventsFor(state, now);
  }

  Future<List<CalendarDay>> _loadMonth(DateTime month) async {
    final userId = ref.read(authControllerProvider)?.id;
    if (userId == null) return const [];
    return ref.read(calendarRepositoryProvider).loadMonth(userId, month);
  }

  Future<void> focusMonth(DateTime month) async {
    final current = state.value;
    final days = await _loadMonth(month);
    final currentSelection = current?.selectedDay;
    final selectionStillInMonth = currentSelection != null &&
        currentSelection.year == month.year &&
        currentSelection.month == month.month;
    final selectedDay = selectionStillInMonth
        ? currentSelection
        : DateTime(month.year, month.month, 1);
    final next =
        CalendarState(focusedMonth: month, selectedDay: selectedDay, days: days);
    state = AsyncData(next);
    state = AsyncData(await _withEventsFor(next, selectedDay));
  }

  Future<void> goToToday() => focusMonth(DateTime.now())
      .then((_) => selectDay(DateTime.now()));

  Future<void> selectDay(DateTime day) async {
    final current = state.value;
    if (current == null) return;
    final next = current.copyWith(selectedDay: day);
    state = AsyncData(next);
    state = AsyncData(await _withEventsFor(next, day));
  }

  /// Fills in the selected day's events lazily — [CalendarRepository.loadMonth]
  /// leaves every day's `events` empty since only the selected day's are
  /// ever shown, so fetching all of them upfront would be wasted work.
  Future<CalendarState> _withEventsFor(CalendarState state, DateTime day) async {
    final userId = ref.read(authControllerProvider)?.id;
    final index = state.days.indexWhere((d) => _sameDate(d.date, day));
    if (userId == null || index == -1) return state;
    if (state.days[index].events.isNotEmpty) return state;

    final events =
        await ref.read(calendarRepositoryProvider).loadEvents(userId, day);
    if (events.isEmpty) return state;
    final updatedDay = CalendarDay(
      date: state.days[index].date,
      type: state.days[index].type,
      plan: state.days[index].plan,
      events: events,
      actualHours: state.days[index].actualHours,
    );
    final days = [...state.days];
    days[index] = updatedDay;
    return state.copyWith(days: days);
  }
}

bool _sameDate(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
