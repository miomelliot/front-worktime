import '../../features/team/domain/department.dart';

const mockDepartments = <Department>[
  Department(
      id: 'eng',
      name: 'Разработка',
      employeeCount: 2,
      managerName: 'Дмитрий Ковалёв'),
  Department(
      id: 'support',
      name: 'Поддержка',
      employeeCount: 1,
      managerName: 'Анна Сидорова'),
  Department(
      id: 'sales',
      name: 'Продажи',
      employeeCount: 1,
      managerName: 'Алексей Смирнов'),
  Department(
      id: 'hr', name: 'HR', employeeCount: 1, managerName: 'Мария Волкова'),
];
