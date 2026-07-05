import '../../../shared/mock/mock_departments.dart';
import '../../../shared/mock/mock_workday.dart';
import '../domain/department.dart';
import '../domain/employee_status.dart';

class FakeTeamRepository {
  Future<List<EmployeeStatus>> loadEmployees() async {
    await Future<void>.delayed(const Duration(milliseconds: 160));
    return mockEmployeeStatuses;
  }

  Future<List<Department>> loadDepartments() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return mockDepartments;
  }
}
