import '../../features/auth/domain/app_user.dart';
import '../../features/auth/domain/user_role.dart';

const mockUsers = <AppUser>[
  AppUser(
    id: 'admin',
    name: 'Admin User',
    email: 'admin@example.test',
    role: UserRole.admin,
    department: 'Operations',
    title: 'System administrator',
  ),
  AppUser(
    id: 'manager',
    name: 'Manager User',
    email: 'manager@example.test',
    role: UserRole.manager,
    department: 'Engineering',
    title: 'Engineering manager',
  ),
  AppUser(
    id: 'ivan',
    name: 'Ivan Petrov',
    email: 'ivan.petrov@example.test',
    role: UserRole.employee,
    department: 'Engineering',
    managerId: 'manager',
    title: 'Backend engineer',
  ),
  AppUser(
    id: 'anna',
    name: 'Anna Sidorova',
    email: 'anna.sidorova@example.test',
    role: UserRole.employee,
    department: 'Support',
    managerId: 'manager',
    title: 'Support specialist',
  ),
  AppUser(
    id: 'alex',
    name: 'Alex Smirnov',
    email: 'alex.smirnov@example.test',
    role: UserRole.employee,
    department: 'Sales',
    managerId: 'manager',
    title: 'Account executive',
  ),
  AppUser(
    id: 'maria',
    name: 'Maria Volkova',
    email: 'maria.volkova@example.test',
    role: UserRole.employee,
    department: 'HR',
    managerId: 'manager',
    title: 'HR partner',
  ),
];
