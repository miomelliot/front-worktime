import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../today/domain/work_status.dart';
import '../data/fake_team_repository.dart';
import '../domain/department.dart';
import '../domain/employee_status.dart';

class TeamState {
  const TeamState({
    required this.employees,
    required this.departments,
    this.query = '',
    this.department = 'All',
    this.status = 'All',
  });

  final List<EmployeeStatus> employees;
  final List<Department> departments;
  final String query;
  final String department;
  final String status;

  List<EmployeeStatus> get filtered {
    return employees.where((employee) {
      final q = query.toLowerCase();
      final matchesQuery = employee.user.name.toLowerCase().contains(q) ||
          employee.user.email.toLowerCase().contains(q);
      final matchesDepartment =
          department == 'All' || employee.user.department == department;
      final matchesStatus = status == 'All' || employee.status.label == status;
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
