import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/domain/auth_state.dart';
import '../../auth/domain/user_profile.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/worktime_models.dart';
import 'worktime_api.dart';

String _currentUserId(Ref ref) {
  final user = ref.watch(authControllerProvider).userOrNull;
  if (user == null) throw StateError('Нет авторизованного пользователя');
  return user.id;
}

final todaySessionProvider = FutureProvider<WorkSession?>((ref) {
  final userId = _currentUserId(ref);
  return ref.watch(worktimeApiProvider).todaySession(userId);
});

final dashboardProvider = FutureProvider<DashboardData>((ref) async {
  final user = ref.watch(authControllerProvider).userOrNull;
  if (user == null) throw StateError('Нет авторизованного пользователя');
  final api = ref.watch(worktimeApiProvider);
  final session = await api.todaySession(user.id);
  final calendar = await api.employeeCalendar(
    userId: user.id,
    from: DateTime.now().subtract(const Duration(days: 7)),
    to: DateTime.now().add(const Duration(days: 21)),
  );
  final summary = await api.violationSummary(userId: user.id);
  return DashboardData(
    session: session,
    calendar: calendar,
    violations: summary,
  );
});

final myCalendarProvider = FutureProvider<EmployeeCalendar>((ref) {
  final userId = _currentUserId(ref);
  final now = DateTime.now();
  final from = DateTime(now.year, now.month);
  final to = DateTime(now.year, now.month + 1, 0);
  return ref.watch(worktimeApiProvider).employeeCalendar(
        userId: userId,
        from: from,
        to: to,
      );
});

final departmentsStateProvider = FutureProvider<DepartmentsState>((ref) {
  return ref.watch(worktimeApiProvider).departmentsState();
});

final workingNowProvider = FutureProvider<List<WorkingNowItem>>((ref) {
  return ref.watch(worktimeApiProvider).workingNow();
});

final usersProvider = FutureProvider<List<UserProfile>>((ref) {
  return ref.watch(worktimeApiProvider).users();
});

final departmentsProvider = FutureProvider<List<Department>>((ref) {
  return ref.watch(worktimeApiProvider).departments();
});

final schedulesProvider = FutureProvider<List<WorkSchedule>>((ref) {
  return ref.watch(worktimeApiProvider).schedules();
});

final scheduleDaysProvider =
    FutureProvider.family<List<WorkScheduleDay>, String>((ref, scheduleId) {
  return ref.watch(worktimeApiProvider).scheduleDays(scheduleId);
});

final absenceTypesProvider = FutureProvider<List<AbsenceType>>((ref) {
  return ref.watch(worktimeApiProvider).absenceTypes();
});

final absencesTodayProvider = FutureProvider<List<Absence>>((ref) {
  return ref.watch(worktimeApiProvider).absencesByDate(DateTime.now());
});

final absencesByDateProvider =
    FutureProvider.family<List<Absence>, DateTime>((ref, date) {
  return ref.watch(worktimeApiProvider).absencesByDate(date);
});

final correctionsForMeProvider = FutureProvider<List<TimeCorrection>>((ref) {
  final userId = _currentUserId(ref);
  return ref.watch(worktimeApiProvider).userCorrections(userId);
});

final correctionsByUserProvider =
    FutureProvider.family<List<TimeCorrection>, String>((ref, userId) {
  return ref.watch(worktimeApiProvider).userCorrections(userId);
});

class DashboardData {
  const DashboardData({
    required this.session,
    required this.calendar,
    required this.violations,
  });

  final WorkSession? session;
  final EmployeeCalendar calendar;
  final ViolationSummary violations;
}
