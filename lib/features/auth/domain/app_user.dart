import 'user_role.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.department,
    this.managerId,
    this.title = 'Team member',
  });

  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String department;
  final String? managerId;
  final String title;
}
