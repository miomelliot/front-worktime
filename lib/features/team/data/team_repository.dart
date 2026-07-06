import '../../../shared/api/api_client.dart';
import '../../../shared/api/time_tracking_helpers.dart';
import '../../auth/domain/app_user.dart';
import '../../auth/domain/user_role.dart';
import '../../today/domain/work_status.dart';
import '../domain/department.dart';
import '../domain/employee_status.dart';

/// Backs the Team tab with the real API. Every role sees the full company
/// roster via `GET /users` — there's no per-manager scoping, so someone
/// without a manager on record still shows up for everyone else. Each
/// member's status (not hours — see [_statusFor]) comes from their own
/// `/time-tracking/session`.
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

  /// [departments] resolves each member's `department_id` to a name; pass
  /// whatever `loadDepartments()` already returned to avoid refetching.
  Future<List<EmployeeStatus>> loadRoster(
    List<Department> departments,
  ) async {
    final departmentNames = {for (final d in departments) d.id: d.name};

    final json = await _client.get('/users');
    final members = (json as List)
        .cast<Map<String, dynamic>>()
        .map((row) => _fromOrganizationJson(row, departmentNames))
        .toList();

    return Future.wait(members.map(_statusFor));
  }

  /// Status only — no hours. The full company roster is visible to every
  /// role now, but planned/worked hours stay a team-scoped concept (fetching
  /// `/users/{id}/workday-plans` for someone outside your own team/reports
  /// isn't permitted), so this intentionally skips that call and leaves
  /// [EmployeeStatus.plannedHours]/[EmployeeStatus.actualHours] at zero —
  /// `EmployeeStatusTile`/`EmployeeStatusTable` already hide the hours bar
  /// when `plannedHours <= 0`.
  Future<EmployeeStatus> _statusFor(AppUser user) async {
    final today = DateTime.now();
    final session = await fetchSession(_client, user.id, today);
    final status = workStatusFromSession(session, isDayOff: false);

    return EmployeeStatus(
      user: user,
      status: status,
      plannedHours: 0,
      actualHours: 0,
      lastEvent: _lastEvent(session, status),
      plan: null,
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
      departmentId: json['department_id'] as String?,
      managerId: json['manager_id'] as String?,
    );
  }
}
