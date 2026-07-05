import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/dio/auth_interceptor.dart';
import '../../../core/dio/dio_client.dart';
import '../domain/auth_response.dart';
import '../domain/user_profile.dart';

/// Thin transport layer for auth-related endpoints.
///
/// This class only knows how to call the HTTP endpoints and decode their
/// bodies into DTOs. It does NOT touch storage or app state — that belongs to
/// the repository. Errors bubble up as raw [DioException]s and are normalized
/// higher up by the repository/controller via `ErrorMapper`.
class AuthApi {
  AuthApi(this._dio);

  final Dio _dio;

  /// Options that tell the [AuthInterceptor] to omit the bearer header — used
  /// for the anonymous endpoints (`/auth/register`, `/auth/login`).
  static final Options _anonymous = Options(
    extra: {AuthInterceptor.skipAuthHeaderKey: true},
  );

  /// `POST /auth/register` -> 201 `AuthResponse`.
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String fullName,
    String? timezone,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/register',
      options: _anonymous,
      data: {
        'email': email,
        'password': password,
        'full_name': fullName,
        // Backend defaults timezone to Europe/Moscow when omitted; only send
        // when the caller supplied one.
        if (timezone != null && timezone.isNotEmpty) 'timezone': timezone,
      },
    );
    return AuthResponse.fromJson(res.data!);
  }

  /// `POST /auth/login` -> 200 `AuthResponse`.
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      options: _anonymous,
      data: {
        'email': email,
        'password': password,
      },
    );
    return AuthResponse.fromJson(res.data!);
  }

  /// `GET /users/me` -> 200 `UserProfile`.
  ///
  /// Preferred over `/auth/me` for app code (both return `UserProfile`). Used
  /// as the auth-state restore endpoint on startup.
  Future<UserProfile> getMe() async {
    final res = await _dio.get<Map<String, dynamic>>('/users/me');
    return UserProfile.fromJson(res.data!);
  }
}

final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(ref.watch(dioProvider));
});
