import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/fake_calendar_repository.dart';
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

final fakeCalendarRepositoryProvider =
    Provider((ref) => FakeCalendarRepository());

final calendarControllerProvider =
    AsyncNotifierProvider<CalendarController, CalendarState>(
        CalendarController.new);

class CalendarController extends AsyncNotifier<CalendarState> {
  @override
  Future<CalendarState> build() async {
    final now = DateTime.now();
    final days = await ref.read(fakeCalendarRepositoryProvider).loadMonth(now);
    return CalendarState(focusedMonth: now, selectedDay: now, days: days);
  }

  Future<void> focusMonth(DateTime month) async {
    final current = state.value;
    final days =
        await ref.read(fakeCalendarRepositoryProvider).loadMonth(month);
    final currentSelection = current?.selectedDay;
    final selectionStillInMonth = currentSelection != null &&
        currentSelection.year == month.year &&
        currentSelection.month == month.month;
    state = AsyncData(
      CalendarState(
        focusedMonth: month,
        selectedDay: selectionStillInMonth
            ? currentSelection
            : DateTime(month.year, month.month, 1),
        days: days,
      ),
    );
  }

  Future<void> goToToday() => focusMonth(DateTime.now())
      .then((_) => selectDay(DateTime.now()));

  void selectDay(DateTime day) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(selectedDay: day));
  }
}

bool _sameDate(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
