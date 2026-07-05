enum UserRole { employee, manager, admin }

extension UserRoleLabel on UserRole {
  String get label {
    switch (this) {
      case UserRole.employee:
        return 'Employee';
      case UserRole.manager:
        return 'Manager';
      case UserRole.admin:
        return 'Admin';
    }
  }
}
