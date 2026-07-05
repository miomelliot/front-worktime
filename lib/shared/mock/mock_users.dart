import '../../features/auth/domain/app_user.dart';
import '../../features/auth/domain/user_role.dart';

const mockUsers = <AppUser>[
  AppUser(
    id: 'admin',
    name: 'Ольга Кузнецова',
    email: 'admin@example.test',
    role: UserRole.admin,
    department: 'Администрация',
    title: 'Системный администратор',
  ),
  AppUser(
    id: 'manager',
    name: 'Дмитрий Ковалёв',
    email: 'manager@example.test',
    role: UserRole.manager,
    department: 'Разработка',
    title: 'Руководитель отдела',
  ),
  AppUser(
    id: 'ivan',
    name: 'Иван Петров',
    email: 'ivan.petrov@example.test',
    role: UserRole.employee,
    department: 'Разработка',
    managerId: 'manager',
    title: 'Backend-разработчик',
  ),
  AppUser(
    id: 'anna',
    name: 'Анна Сидорова',
    email: 'anna.sidorova@example.test',
    role: UserRole.employee,
    department: 'Поддержка',
    managerId: 'manager',
    title: 'Специалист поддержки',
  ),
  AppUser(
    id: 'alex',
    name: 'Алексей Смирнов',
    email: 'alex.smirnov@example.test',
    role: UserRole.employee,
    department: 'Продажи',
    managerId: 'manager',
    title: 'Менеджер по продажам',
  ),
  AppUser(
    id: 'maria',
    name: 'Мария Волкова',
    email: 'maria.volkova@example.test',
    role: UserRole.employee,
    department: 'HR',
    managerId: 'manager',
    title: 'HR-партнёр',
  ),
];
