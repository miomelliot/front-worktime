import 'package:freezed_annotation/freezed_annotation.dart';

import '../../shared_models/enums.dart';

part 'worktime_models.freezed.dart';
part 'worktime_models.g.dart';

@freezed
class WorkSession with _$WorkSession {
  const factory WorkSession({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'work_plan_id') String? workPlanId,
    @JsonKey(name: 'work_date') required DateTime workDate,
    @JsonKey(name: 'started_at') DateTime? startedAt,
    @JsonKey(name: 'stopped_at') DateTime? stoppedAt,
    required WorkSessionStatus status,
    @JsonKey(name: 'worked_seconds') @Default(0) int workedSeconds,
    @JsonKey(name: 'pause_seconds') @Default(0) int pauseSeconds,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _WorkSession;

  factory WorkSession.fromJson(Map<String, dynamic> json) =>
      _$WorkSessionFromJson(json);
}

@freezed
class TimeEvent with _$TimeEvent {
  const factory TimeEvent({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'session_id') String? sessionId,
    @JsonKey(name: 'event_type') required TimeEventType eventType,
    @JsonKey(name: 'event_time') required DateTime eventTime,
    required String source,
    @JsonKey(name: 'external_event_id') String? externalEventId,
    @JsonKey(name: 'is_automatic') @Default(false) bool isAutomatic,
    String? payload,
    @JsonKey(name: 'work_date') required DateTime workDate,
    @JsonKey(name: 'created_by') String? createdBy,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _TimeEvent;

  factory TimeEvent.fromJson(Map<String, dynamic> json) =>
      _$TimeEventFromJson(json);
}

@freezed
class TrackingResult with _$TrackingResult {
  const factory TrackingResult({
    required WorkSession session,
    required TimeEvent event,
  }) = _TrackingResult;

  factory TrackingResult.fromJson(Map<String, dynamic> json) =>
      _$TrackingResultFromJson(json);
}

@freezed
class EmployeeCalendar with _$EmployeeCalendar {
  const factory EmployeeCalendar({
    @JsonKey(name: 'user_id') required String userId,
    required DateTime from,
    required DateTime to,
    @Default([]) List<CalendarDay> days,
  }) = _EmployeeCalendar;

  factory EmployeeCalendar.fromJson(Map<String, dynamic> json) =>
      _$EmployeeCalendarFromJson(json);
}

@freezed
class CalendarDay with _$CalendarDay {
  const factory CalendarDay({
    required DateTime date,
    @JsonKey(name: 'is_working') required bool isWorking,
    @JsonKey(name: 'plan_status') WorkPlanStatus? planStatus,
    @JsonKey(name: 'plan_source') WorkPlanSource? planSource,
    @JsonKey(name: 'day_status') DayStatus? dayStatus,
    @JsonKey(name: 'absence_status') AbsenceStatus? absenceStatus,
    @JsonKey(name: 'absence_type_id') String? absenceTypeId,
    @JsonKey(name: 'expected_seconds') @Default(0) int expectedSeconds,
    @JsonKey(name: 'worked_seconds') @Default(0) int workedSeconds,
    @JsonKey(name: 'planned_start_at') DateTime? plannedStartAt,
    @JsonKey(name: 'planned_end_at') DateTime? plannedEndAt,
  }) = _CalendarDay;

  factory CalendarDay.fromJson(Map<String, dynamic> json) =>
      _$CalendarDayFromJson(json);
}

@freezed
class WorkingNowItem with _$WorkingNowItem {
  const factory WorkingNowItem({
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'full_name') required String fullName,
    required String email,
    @JsonKey(name: 'department_id') String? departmentId,
    @JsonKey(name: 'manager_id') String? managerId,
    @JsonKey(name: 'session_id') required String sessionId,
    required WorkSessionStatus status,
    @JsonKey(name: 'started_at') DateTime? startedAt,
    @JsonKey(name: 'worked_seconds') @Default(0) int workedSeconds,
    @JsonKey(name: 'pause_seconds') @Default(0) int pauseSeconds,
  }) = _WorkingNowItem;

  factory WorkingNowItem.fromJson(Map<String, dynamic> json) =>
      _$WorkingNowItemFromJson(json);
}

@freezed
class TeamMemberState with _$TeamMemberState {
  const factory TeamMemberState({
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'full_name') required String fullName,
    required String email,
    @JsonKey(name: 'department_id') String? departmentId,
    @JsonKey(name: 'session_id') String? sessionId,
    @JsonKey(name: 'session_status') WorkSessionStatus? sessionStatus,
    @JsonKey(name: 'open_violations') @Default(0) int openViolations,
    @JsonKey(name: 'today_day_status') DayStatus? todayDayStatus,
    @JsonKey(name: 'worked_seconds') @Default(0) int workedSeconds,
    @JsonKey(name: 'expected_seconds') @Default(0) int expectedSeconds,
  }) = _TeamMemberState;

  factory TeamMemberState.fromJson(Map<String, dynamic> json) =>
      _$TeamMemberStateFromJson(json);
}

@freezed
class TeamState with _$TeamState {
  const factory TeamState({
    @JsonKey(name: 'manager_id') required String managerId,
    @JsonKey(name: 'total_employees') @Default(0) int totalEmployees,
    @Default(0) int working,
    @Default(0) int paused,
    @Default(0) int finished,
    @JsonKey(name: 'without_session') @Default(0) int withoutSession,
    @JsonKey(name: 'open_violations') @Default(0) int openViolations,
    @Default([]) List<TeamMemberState> members,
  }) = _TeamState;

  factory TeamState.fromJson(Map<String, dynamic> json) =>
      _$TeamStateFromJson(json);
}

@freezed
class DepartmentsState with _$DepartmentsState {
  const factory DepartmentsState({
    @JsonKey(name: 'total_departments') @Default(0) int totalDepartments,
    @JsonKey(name: 'total_employees') @Default(0) int totalEmployees,
    @Default(0) int working,
    @Default(0) int paused,
    @Default(0) int finished,
    @JsonKey(name: 'without_session') @Default(0) int withoutSession,
    @JsonKey(name: 'open_violations') @Default(0) int openViolations,
    @Default([]) List<DepartmentState> departments,
  }) = _DepartmentsState;

  factory DepartmentsState.fromJson(Map<String, dynamic> json) =>
      _$DepartmentsStateFromJson(json);
}

@freezed
class DepartmentState with _$DepartmentState {
  const factory DepartmentState({
    @JsonKey(name: 'department_id') String? departmentId,
    @JsonKey(name: 'department_name') required String departmentName,
    @JsonKey(name: 'total_employees') @Default(0) int totalEmployees,
    @Default(0) int working,
    @Default(0) int paused,
    @Default(0) int finished,
    @JsonKey(name: 'without_session') @Default(0) int withoutSession,
    @JsonKey(name: 'open_violations') @Default(0) int openViolations,
    @Default([]) List<TeamMemberState> employees,
  }) = _DepartmentState;

  factory DepartmentState.fromJson(Map<String, dynamic> json) =>
      _$DepartmentStateFromJson(json);
}

@freezed
class ViolationSummary with _$ViolationSummary {
  const factory ViolationSummary({
    @Default(0) int open,
    @Default(0) int resolved,
    @Default(0) int ignored,
    @Default(0) int total,
  }) = _ViolationSummary;

  factory ViolationSummary.fromJson(Map<String, dynamic> json) =>
      _$ViolationSummaryFromJson(json);
}

@freezed
class Department with _$Department {
  const factory Department({
    required String id,
    required String name,
    @JsonKey(name: 'parent_id') String? parentId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _Department;

  factory Department.fromJson(Map<String, dynamic> json) =>
      _$DepartmentFromJson(json);
}

@freezed
class UserOrganization with _$UserOrganization {
  const factory UserOrganization({
    required String id,
    required String email,
    @JsonKey(name: 'full_name') required String fullName,
    required RoleCode role,
    required UserStatus status,
    @JsonKey(name: 'department_id') String? departmentId,
    @JsonKey(name: 'manager_id') String? managerId,
  }) = _UserOrganization;

  factory UserOrganization.fromJson(Map<String, dynamic> json) =>
      _$UserOrganizationFromJson(json);
}

@freezed
class WorkSchedule with _$WorkSchedule {
  const factory WorkSchedule({
    required String id,
    required String name,
    @JsonKey(name: 'schedule_type') required ScheduleType scheduleType,
    required String timezone,
    @JsonKey(name: 'start_grace_seconds') @Default(0) int startGraceSeconds,
    @JsonKey(name: 'stop_grace_seconds') @Default(0) int stopGraceSeconds,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _WorkSchedule;

  factory WorkSchedule.fromJson(Map<String, dynamic> json) =>
      _$WorkScheduleFromJson(json);
}

@freezed
class WorkScheduleDay with _$WorkScheduleDay {
  const factory WorkScheduleDay({
    required String id,
    @JsonKey(name: 'schedule_id') required String scheduleId,
    required int weekday,
    @JsonKey(name: 'is_working') required bool isWorking,
    @JsonKey(name: 'start_time') int? startTime,
    @JsonKey(name: 'end_time') int? endTime,
    @JsonKey(name: 'break_seconds') @Default(0) int breakSeconds,
    @JsonKey(name: 'expected_seconds') @Default(0) int expectedSeconds,
  }) = _WorkScheduleDay;

  factory WorkScheduleDay.fromJson(Map<String, dynamic> json) =>
      _$WorkScheduleDayFromJson(json);
}

@freezed
class ScheduleAssignment with _$ScheduleAssignment {
  const factory ScheduleAssignment({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'schedule_id') required String scheduleId,
    @JsonKey(name: 'valid_from') required DateTime validFrom,
    @JsonKey(name: 'valid_to') DateTime? validTo,
    @JsonKey(name: 'assigned_by') String? assignedBy,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _ScheduleAssignment;

  factory ScheduleAssignment.fromJson(Map<String, dynamic> json) =>
      _$ScheduleAssignmentFromJson(json);
}

@freezed
class AbsenceType with _$AbsenceType {
  const factory AbsenceType({
    required String id,
    required String code,
    required String name,
    @JsonKey(name: 'affects_work_plan') required bool affectsWorkPlan,
    @JsonKey(name: 'requires_document') required bool requiresDocument,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _AbsenceType;

  factory AbsenceType.fromJson(Map<String, dynamic> json) =>
      _$AbsenceTypeFromJson(json);
}

@freezed
class Absence with _$Absence {
  const factory Absence({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'absence_type_id') required String absenceTypeId,
    @JsonKey(name: 'date_from') required DateTime dateFrom,
    @JsonKey(name: 'date_to') required DateTime dateTo,
    @JsonKey(name: 'day_part') required AbsenceDayPart dayPart,
    @JsonKey(name: 'time_from') int? timeFrom,
    @JsonKey(name: 'time_to') int? timeTo,
    required AbsenceStatus status,
    required AbsenceSource source,
    String? reason,
    @JsonKey(name: 'created_by') required String createdBy,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'cancelled_by') String? cancelledBy,
    @JsonKey(name: 'cancelled_at') DateTime? cancelledAt,
    @JsonKey(name: 'cancel_reason') String? cancelReason,
  }) = _Absence;

  factory Absence.fromJson(Map<String, dynamic> json) =>
      _$AbsenceFromJson(json);
}

@freezed
class TimeCorrection with _$TimeCorrection {
  const factory TimeCorrection({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'session_id') String? sessionId,
    @JsonKey(name: 'work_date') required DateTime workDate,
    required CorrectionStatus status,
    @JsonKey(name: 'old_value') String? oldValue,
    @JsonKey(name: 'new_value') required String newValue,
    required String reason,
    @JsonKey(name: 'created_time_event_id') String? createdTimeEventId,
    @JsonKey(name: 'created_by') required String createdBy,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'cancelled_by') String? cancelledBy,
    @JsonKey(name: 'cancelled_at') DateTime? cancelledAt,
    @JsonKey(name: 'cancel_reason') String? cancelReason,
  }) = _TimeCorrection;

  factory TimeCorrection.fromJson(Map<String, dynamic> json) =>
      _$TimeCorrectionFromJson(json);
}
