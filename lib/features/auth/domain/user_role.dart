enum UserRole {
  employee,
  manager,
  admin;

  /// Parses the backend's `role` string (`employee`/`manager`/`admin`).
  factory UserRole.fromApi(String value) => UserRole.values.firstWhere(
        (role) => role.name == value,
        orElse: () => UserRole.employee,
      );
}

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
