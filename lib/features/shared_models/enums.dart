import 'package:json_annotation/json_annotation.dart';

/// Cross-feature enums, mirroring the backend's enum vocabularies exactly.
///
/// Each value carries a `@JsonValue` so it round-trips against the wire
/// strings. These are intentionally centralized so every feature decodes the
/// same set — do NOT invent additional members that the backend does not send.

enum RoleCode {
  @JsonValue('employee')
  employee,
  @JsonValue('manager')
  manager,
  @JsonValue('admin')
  admin,
}

enum UserStatus {
  @JsonValue('active')
  active,
  @JsonValue('blocked')
  blocked,
  @JsonValue('fired')
  fired,
}

enum AuthProvider {
  @JsonValue('local')
  local,
  @JsonValue('lk_sso')
  lkSso,
  @JsonValue('oidc')
  oidc,
}

enum ScheduleType {
  @JsonValue('weekly')
  weekly,
  @JsonValue('flexible')
  flexible,
  @JsonValue('shift')
  shift,
  @JsonValue('custom')
  custom,
}

enum CalendarDayType {
  @JsonValue('workday')
  workday,
  @JsonValue('weekend')
  weekend,
  @JsonValue('holiday')
  holiday,
  @JsonValue('shortened')
  shortened,
}

enum WorkSessionStatus {
  @JsonValue('working')
  working,
  @JsonValue('paused')
  paused,
  @JsonValue('finished')
  finished,
  @JsonValue('incomplete')
  incomplete,
}

enum TimeEventType {
  @JsonValue('work_started')
  workStarted,
  @JsonValue('work_paused')
  workPaused,
  @JsonValue('work_resumed')
  workResumed,
  @JsonValue('work_stopped')
  workStopped,
  @JsonValue('manual_adjustment')
  manualAdjustment,
}

enum DayStatus {
  @JsonValue('not_started')
  notStarted,
  @JsonValue('working')
  working,
  @JsonValue('paused')
  paused,
  @JsonValue('finished')
  finished,
  @JsonValue('incomplete')
  incomplete,
  @JsonValue('day_off')
  dayOff,
  @JsonValue('holiday')
  holiday,
  @JsonValue('vacation')
  vacation,
  @JsonValue('sick_leave')
  sickLeave,
  @JsonValue('business_trip')
  businessTrip,
  @JsonValue('unpaid_leave')
  unpaidLeave,
  @JsonValue('day_off_absence')
  dayOffAbsence,
  @JsonValue('absence')
  absence,
  @JsonValue('underworked')
  underworked,
  @JsonValue('violation')
  violation,
  @JsonValue('unknown')
  unknown,
}

enum WorkPlanSource {
  @JsonValue('schedule')
  schedule,
  @JsonValue('production_calendar')
  productionCalendar,
  @JsonValue('individual_override')
  individualOverride,
  @JsonValue('absence')
  absence,
  @JsonValue('generated')
  generated,
}

enum WorkPlanStatus {
  @JsonValue('planned')
  planned,
  @JsonValue('changed')
  changed,
  @JsonValue('cancelled')
  cancelled,
}

enum AbsenceDayPart {
  @JsonValue('full_day')
  fullDay,
  @JsonValue('first_half')
  firstHalf,
  @JsonValue('second_half')
  secondHalf,
  @JsonValue('custom_time')
  customTime,
}

enum AbsenceStatus {
  @JsonValue('active')
  active,
  @JsonValue('cancelled')
  cancelled,
}

enum AbsenceSource {
  @JsonValue('manager')
  manager,
  @JsonValue('admin')
  admin,
  @JsonValue('import')
  import,
  @JsonValue('self_request')
  selfRequest,
}

enum CorrectionStatus {
  @JsonValue('applied')
  applied,
  @JsonValue('cancelled')
  cancelled,
}

enum ViolationType {
  @JsonValue('not_started_before_deadline')
  notStartedBeforeDeadline,
  @JsonValue('not_stopped_after_workday')
  notStoppedAfterWorkday,
  @JsonValue('pause_too_long')
  pauseTooLong,
  @JsonValue('underworked')
  underworked,
  @JsonValue('unexpected_work_on_day_off')
  unexpectedWorkOnDayOff,
}

enum ViolationStatus {
  @JsonValue('open')
  open,
  @JsonValue('resolved')
  resolved,
  @JsonValue('ignored')
  ignored,
}
