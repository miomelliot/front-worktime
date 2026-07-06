import 'user_role.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.department,
    this.departmentId,
    this.managerId,
    this.title,
    this.status = 'active',
    this.avatarUrl,
    this.timezone = 'Europe/Moscow',
  });

  final String id;
  final String name;
  final String email;
  final UserRole role;

  /// Department *name* — only resolvable where the backend exposes a
  /// `department_id` (team-listing/org endpoints) and the caller has
  /// separately looked up the name via `GET /departments`. Null when
  /// unknown, e.g. on a user's own `/users/me` response, which carries no
  /// department at all.
  final String? department;

  /// Raw `department_id` — used to match "same department" between users
  /// (e.g. for the Today tab's colleagues card) without relying on
  /// [department] name lookups being available.
  final String? departmentId;
  final String? managerId;

  /// Backend calls this "position" — kept as `title` since that's what the
  /// UI already reads everywhere.
  final String? title;
  final String status;
  final String? avatarUrl;
  final String timezone;

  /// Parses the `UserProfile` shape returned by `/auth/me`, `/users/me`,
  /// `/users/{id}` and the login response's `user` field.
  factory AppUser.fromProfileJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as String,
        name: json['full_name'] as String,
        email: json['email'] as String,
        role: UserRole.fromApi(json['role'] as String),
        title: json['position'] as String?,
        status: json['status'] as String? ?? 'active',
        avatarUrl: json['avatar_url'] as String?,
        timezone: json['timezone'] as String? ?? 'Europe/Moscow',
        managerId: json['manager_id'] as String?,
        departmentId: json['department_id'] as String?,
      );

  /// Round-trips through [fromProfileJson] — used to cache the session in
  /// local storage so it survives a browser restart.
  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'full_name': name,
        'role': role.name,
        'status': status,
        'timezone': timezone,
        if (title != null) 'position': title,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        if (managerId != null) 'manager_id': managerId,
        if (departmentId != null) 'department_id': departmentId,
      };
}
