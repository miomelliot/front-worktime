enum UserRole { employee, manager, admin }

extension UserRoleLabel on UserRole {
  String get label {
    switch (this) {
      case UserRole.employee:
        return 'Сотрудник';
      case UserRole.manager:
        return 'Менеджер';
      case UserRole.admin:
        return 'Администратор';
    }
  }
}
