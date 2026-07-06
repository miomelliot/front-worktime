import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/api/api_client.dart';
import '../../auth/application/auth_controller.dart';
import '../../today/domain/work_status.dart';
import '../data/team_repository.dart';
import '../domain/department.dart';
import '../domain/employee_status.dart';

const teamFilterAll = 'Все';

class TeamDepartmentGroup {
  const TeamDepartmentGroup({required this.name, required this.employees});

  final String name;
  final List<EmployeeStatus> employees;
}

class TeamState {
  const TeamState({
    required this.employees,
    required this.departments,
    this.viewerId,
    this.viewerDepartmentId,
    this.query = '',
    this.department = teamFilterAll,
    this.status = teamFilterAll,
    this.filtersEpoch = 0,
  });

  final List<EmployeeStatus> employees;
  final List<Department> departments;

  /// The signed-in user's own id/department — not affected by filters.
  /// Used to derive "my department colleagues" (e.g. for the Today tab's
  /// colleagues card) from the full [employees] roster.
  final String? viewerId;
  final String? viewerDepartmentId;
  final String query;
  final String department;
  final String status;

  /// Bumped only by [TeamController.resetFilters], never by typing — lets
  /// the search field's widget key drop stale text on reset without
  /// remounting (and losing focus) on every keystroke.
  final int filtersEpoch;

  bool get hasActiveFilters =>
      query.isNotEmpty ||
      department != teamFilterAll ||
      status != teamFilterAll;

  /// Distinct status labels actually present among [employees], in the
  /// order [WorkStatus] declares them, so the filter never offers a choice
  /// that would return zero results.
  List<String> get availableStatuses => WorkStatus.values
      .where((value) => employees.any((employee) => employee.status == value))
      .map((value) => value.label)
      .toList();

  /// Distinct department names actually present among [employees] (not
  /// [filtered] — the option list shouldn't shrink as soon as you pick one),
  /// ordered like [departments] with any unlisted name appended after.
  List<String> get availableDepartments =>
      _orderedDepartmentNames(employees, departments);

  /// Other employees sharing the viewer's department, unaffected by the
  /// search/status/department filters below. Empty when the viewer has no
  /// department on record — there's no "colleagues" group to show then.
  List<EmployeeStatus> get departmentColleagues {
    final departmentId = viewerDepartmentId;
    if (departmentId == null) return const [];
    return employees
        .where((employee) =>
            employee.user.departmentId == departmentId &&
            employee.user.id != viewerId)
        .toList();
  }

  List<EmployeeStatus> get filtered {
    return employees.where((employee) {
      final q = query.trim().toLowerCase();
      final matchesQuery = q.isEmpty ||
          employee.user.name.toLowerCase().contains(q) ||
          employee.user.email.toLowerCase().contains(q);
      final matchesDepartment = department == teamFilterAll ||
          employee.user.department == department;
      final matchesStatus =
          status == teamFilterAll || employee.status.label == status;
      return matchesQuery && matchesDepartment && matchesStatus;
    }).toList();
  }

  /// [filtered] employees bucketed by department, ordered like
  /// [departments] with any department that has no entry there (e.g. an
  /// admin's own department) appended after, in first-seen order.
  List<TeamDepartmentGroup> get filteredByDepartment {
    final byDepartment = <String, List<EmployeeStatus>>{};
    for (final employee in filtered) {
      final department = employee.user.department ?? 'Без отдела';
      (byDepartment[department] ??= []).add(employee);
    }
    final order = _orderedDepartmentNames(filtered, departments);
    return [
      for (final name in order)
        TeamDepartmentGroup(name: name, employees: byDepartment[name]!),
    ];
  }

  TeamState copyWith({String? query, String? department, String? status}) {
    return TeamState(
      employees: employees,
      departments: departments,
      viewerId: viewerId,
      viewerDepartmentId: viewerDepartmentId,
      query: query ?? this.query,
      department: department ?? this.department,
      status: status ?? this.status,
      filtersEpoch: filtersEpoch,
    );
  }
}

/// Names of departments actually represented in [source], ordered like
/// [departments] with any unlisted name (e.g. a bucket only reachable
/// through a role that can't resolve department names) appended after.
List<String> _orderedDepartmentNames(
  List<EmployeeStatus> source,
  List<Department> departments,
) {
  final present = <String>{
    for (final employee in source) employee.user.department ?? 'Без отдела',
  };
  return [
    for (final d in departments)
      if (present.contains(d.name)) d.name,
    for (final name in present)
      if (!departments.any((d) => d.name == name)) name,
  ];
}

final teamRepositoryProvider =
    Provider((ref) => TeamRepository(ref.watch(apiClientProvider)));

final teamControllerProvider =
    AsyncNotifierProvider<TeamController, TeamState>(TeamController.new);

class TeamController extends AsyncNotifier<TeamState> {
  @override
  Future<TeamState> build() async {
    // Watched so switching users on the same device (logout → login as
    // someone else) re-fetches instead of leaving the previous user's
    // roster cached.
    final actor = ref.watch(authControllerProvider);
    if (actor == null) return const TeamState(employees: [], departments: []);

    final repository = ref.read(teamRepositoryProvider);
    final departments = await repository.loadDepartments();
    final roster = await repository.loadRoster(departments);
    return TeamState(
      employees: roster,
      departments: departments,
      viewerId: actor.id,
      viewerDepartmentId: actor.departmentId,
    );
  }

  void setQuery(String value) =>
      _update((state) => state.copyWith(query: value));
  void setDepartment(String value) =>
      _update((state) => state.copyWith(department: value));
  void setStatus(String value) =>
      _update((state) => state.copyWith(status: value));
  void resetFilters() => _update((state) => TeamState(
        employees: state.employees,
        departments: state.departments,
        viewerId: state.viewerId,
        viewerDepartmentId: state.viewerDepartmentId,
        filtersEpoch: state.filtersEpoch + 1,
      ));

  EmployeeStatus? findEmployee(String id) {
    final current = state.value;
    if (current == null) return null;
    return current.employees
        .where((employee) => employee.user.id == id)
        .firstOrNull;
  }

  void _update(TeamState Function(TeamState state) transform) {
    final current = state.value;
    if (current != null) state = AsyncData(transform(current));
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
