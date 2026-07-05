import '../../features/team/domain/employee_status.dart';
import '../../features/today/domain/time_event.dart';
import '../../features/today/domain/work_session.dart';
import '../../features/today/domain/work_status.dart';
import '../../features/today/domain/workday_plan.dart';
import 'mock_users.dart';

DateTime get mockToday => DateTime.now();

WorkdayPlan standardPlan([DateTime? date]) {
  return WorkdayPlan(
    date: date ?? mockToday,
    plannedStart: '09:00',
    plannedEnd: '18:00',
    expectedHours: 8,
    breakMinutes: 60,
  );
}

WorkdayPlan shortenedPlan([DateTime? date]) {
  return WorkdayPlan(
    date: date ?? mockToday,
    plannedStart: '09:00',
    plannedEnd: '17:00',
    expectedHours: 7,
    breakMinutes: 60,
    isShortened: true,
  );
}

WorkdayPlan dayOffPlan([DateTime? date]) {
  return WorkdayPlan(
    date: date ?? mockToday,
    plannedStart: '-',
    plannedEnd: '-',
    expectedHours: 0,
    breakMinutes: 0,
    isDayOff: true,
  );
}

WorkdayPlan holidayPlan([DateTime? date]) {
  return WorkdayPlan(
    date: date ?? mockToday,
    plannedStart: '-',
    plannedEnd: '-',
    expectedHours: 0,
    breakMinutes: 0,
    isDayOff: true,
    isHoliday: true,
  );
}

final mockEvents = <TimeEvent>[
  TimeEvent(
      action: 'start',
      time: DateTime.now().copyWith(hour: 9, minute: 4),
      note: 'Рабочий день начат'),
  TimeEvent(
      action: 'pause',
      time: DateTime.now().copyWith(hour: 12, minute: 32),
      note: 'Обеденный перерыв'),
  TimeEvent(
      action: 'resume',
      time: DateTime.now().copyWith(hour: 13, minute: 14),
      note: 'Вернулся к работе'),
];

final mockTodaySession = WorkSession(
  status: WorkStatus.working,
  elapsed: const Duration(hours: 5, minutes: 24),
  plan: standardPlan(),
  events: mockEvents,
);

final mockEmployeeStatuses = <EmployeeStatus>[
  EmployeeStatus(
      user: mockUsers[2],
      status: WorkStatus.working,
      plannedHours: 8,
      actualHours: 5.4,
      lastEvent: 'Начал в 09:04'),
  EmployeeStatus(
      user: mockUsers[3],
      status: WorkStatus.paused,
      plannedHours: 8,
      actualHours: 3.8,
      lastEvent: 'Пауза с 12:20'),
  EmployeeStatus(
      user: mockUsers[4],
      status: WorkStatus.stopped,
      plannedHours: 8,
      actualHours: 7.9,
      lastEvent: 'Завершил в 17:46'),
  EmployeeStatus(
      user: mockUsers[5],
      status: WorkStatus.dayOff,
      plannedHours: 0,
      actualHours: 0,
      lastEvent: 'Выходной день'),
  EmployeeStatus(
      user: mockUsers[1],
      status: WorkStatus.vacationDisplayOnly,
      plannedHours: 0,
      actualHours: 0,
      lastEvent: 'В отпуске'),
  EmployeeStatus(
      user: mockUsers[0],
      status: WorkStatus.sickDisplayOnly,
      plannedHours: 0,
      actualHours: 0,
      lastEvent: 'На больничном'),
];
