import '../../features/team/domain/department.dart';

const mockDepartments = <Department>[
  Department(
      id: 'eng',
      name: 'Engineering',
      employeeCount: 2,
      managerName: 'Manager User'),
  Department(
      id: 'support',
      name: 'Support',
      employeeCount: 1,
      managerName: 'Anna Sidorova'),
  Department(
      id: 'sales',
      name: 'Sales',
      employeeCount: 1,
      managerName: 'Alex Smirnov'),
  Department(
      id: 'hr', name: 'HR', employeeCount: 1, managerName: 'Maria Volkova'),
];
