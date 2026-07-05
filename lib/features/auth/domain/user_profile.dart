import 'package:freezed_annotation/freezed_annotation.dart';

import '../../shared_models/enums.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

/// `UserProfile` DTO — returned by `/users/me`, `/auth/me`, `/users`,
/// `/users/{id}`, and `/users/{id}/role`.
///
/// Field names match the wire contract exactly. `position` and `avatar_url`
/// are optional and may be omitted by the backend.
@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String email,
    @JsonKey(name: 'full_name') required String fullName,
    required RoleCode role,
    required UserStatus status,
    @JsonKey(name: 'auth_provider') required AuthProvider authProvider,
    required String timezone,
    String? position,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}

/// Convenience role checks used for router redirects and UI gating.
extension UserProfileX on UserProfile {
  bool get isAdmin => role == RoleCode.admin;
  bool get isManager => role == RoleCode.manager;
  bool get isEmployee => role == RoleCode.employee;

  /// Managers and admins can see organization/team dashboards.
  bool get canViewOrgDashboards =>
      role == RoleCode.manager || role == RoleCode.admin;

  bool get isActive => status == UserStatus.active;

  /// Local-auth users may change their own password.
  bool get canChangePassword => authProvider == AuthProvider.local;
}
