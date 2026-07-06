import 'app_user.dart';

/// Result of a successful `/auth/login` (or `/auth/register`) call.
class AuthSession {
  const AuthSession({
    required this.user,
    required this.accessToken,
    required this.expiresAt,
  });

  final AppUser user;
  final String accessToken;
  final DateTime expiresAt;

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
        user: AppUser.fromProfileJson(json['user'] as Map<String, dynamic>),
        accessToken: json['access_token'] as String,
        expiresAt: DateTime.parse(json['expires_at'] as String),
      );
}
