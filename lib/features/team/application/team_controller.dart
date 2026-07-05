import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../today/domain/work_status.dart';
import '../data/fake_team_repository.dart';
import '../domain/department.dart';
import '../domain/employee_status.dart';

const teamFilterAll = 'Все';

class TeamState {
  const TeamState({
    required this.employees,
    required this.departments,
    this.query = '',
    this.department = teamFilterAll,
    this.status = teamFilterAll,
    this.filtersEpoch = 0,
  });

  final List<EmployeeStatus> employees;
  final List<Department> departments;
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

  TeamState copyWith({String? query, String? department, String? status}) {
    return TeamState(
      employees: employees,
      departments: departments,
      query: query ?? this.query,
      department: department ?? this.department,
      status: status ?? this.status,
      filtersEpoch: filtersEpoch,
    );
  }
}

final fakeTeamRepositoryProvider = Provider((ref) => FakeTeamRepository());

final teamControllerProvider =
    AsyncNotifierProvider<TeamController, TeamState>(TeamController.new);

class TeamController extends AsyncNotifier<TeamState> {
  @override
  Future<TeamState> build() async {
    final repository = ref.read(fakeTeamRepositoryProvider);
    return TeamState(
      employees: await repository.loadEmployees(),
      departments: await repository.loadDepartments(),
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
