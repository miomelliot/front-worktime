import 'package:freezed_annotation/freezed_annotation.dart';

import 'user_profile.dart';

part 'auth_response.freezed.dart';
part 'auth_response.g.dart';

/// `AuthResponse` DTO — returned by `/auth/register` (201) and
/// `/auth/login` (200).
///
/// The backend returns ONLY these three fields. There is no refresh token,
/// so none is modeled here.
@freezed
class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    required UserProfile user,
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'expires_at') required DateTime expiresAt,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}
