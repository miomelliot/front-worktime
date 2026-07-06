import '../../../shared/api/api_client.dart';
import '../../../shared/api/time_tracking_helpers.dart';
import '../../auth/domain/app_user.dart';
import '../../auth/domain/user_role.dart';
import '../../today/domain/work_status.dart';
import '../../today/domain/workday_plan.dart';
import '../domain/department.dart';
import '../domain/employee_status.dart';

/// Backs the Team tab with the real API. What a caller can see is dictated
/// entirely by their role — there is no single "list everyone" endpoint
/// available to a plain employee:
///  - admin: `GET /users` (global roster, no department per user)
///  - manager: `GET /managers/{id}/team` (direct reports, with department_id)
///  - employee: nothing — the backend has no team-listing endpoint for them
class TeamRepository {
  const TeamRepository(this._client);

  final ApiClient _client;

  Future<List<Department>> loadDepartments() async {
    final json = await _client.get('/departments');
    return (json as List)
        .cast<Map<String, dynamic>>()
        .map(Department.fromJson)
        .toList();
  }

  /// Null return means "this role has no team-listing capability" — distinct
  /// from an empty list (a manager with zero reports). [departments]
  /// resolves each report's `department_id` to a name for a manager's team;
  /// pass whatever `loadDepartments()` already returned to avoid refetching.
  Future<List<EmployeeStatus>?> loadRoster(
    AppUser actor,
    List<Department> departments,
  ) async {
    final departmentNames = {for (final d in departments) d.id: d.name};

    final List<AppUser> members;
    switch (actor.role) {
      case UserRole.admin:
        final json = await _client.get('/users');
        members = (json as List)
            .cast<Map<String, dynamic>>()
            .map(AppUser.fromProfileJson)
            .toList();
      case UserRole.manager:
        final json = await _client.get('/managers/${actor.id}/team');
        members = (json as List)
            .cast<Map<String, dynamic>>()
            .map((row) => _fromOrganizationJson(row, departmentNames))
            .toList();
      case UserRole.employee:
        return null;
    }

    return Future.wait(members.map(_statusFor));
  }

  Future<EmployeeStatus> _statusFor(AppUser user) async {
    final today = DateTime.now();
    final results = await Future.wait([
      fetchSession(_client, user.id, today),
      _client.get('/users/${user.id}/workday-plans'),
    ]);

    final session = results[0] as Map<String, dynamic>?;
    final plans = (results[1] as List).cast<Map<String, dynamic>>();
    final planJson = plans.firstWhereOrNull(
      (p) => sameDate(DateTime.parse(p['work_date'] as String), today),
    );
    final plan = planJson != null ? WorkdayPlan.fromJson(planJson) : null;

    final status =
        workStatusFromSession(session, isDayOff: plan?.isDayOff ?? false);
    final workedSeconds = (session?['worked_seconds'] as num?) ?? 0;

    return EmployeeStatus(
      user: user,
      status: status,
      plannedHours: plan?.expectedHours ?? 0,
      actualHours: workedSeconds / 3600.0,
      lastEvent: _lastEvent(session, status),
      plan: plan,
    );
  }

  String _lastEvent(Map<String, dynamic>? session, WorkStatus status) {
    final startedAt = session?['started_at'] as String?;
    final stoppedAt = session?['stopped_at'] as String?;
    switch (status) {
      case WorkStatus.working:
        return startedAt != null ? 'Работает с ${hhmm(startedAt)}' : 'Работает';
      case WorkStatus.paused:
        return 'На паузе';
      case WorkStatus.stopped:
        return stoppedAt != null ? 'Завершил в ${hhmm(stoppedAt)}' : 'Завершил';
      case WorkStatus.incomplete:
        return 'Смена не завершена штатно';
      case WorkStatus.dayOff:
        return 'Выходной день';
      default:
        return 'Не начат';
    }
  }

  AppUser _fromOrganizationJson(
    Map<String, dynamic> json,
    Map<String, String> departmentNames,
  ) {
    return AppUser(
      id: json['id'] as String,
      name: json['full_name'] as String,
      email: json['email'] as String,
      role: UserRole.fromApi(json['role'] as String),
      status: json['status'] as String? ?? 'active',
      department: departmentNames[json['department_id']],
      managerId: json['manager_id'] as String?,
    );
  }
}
