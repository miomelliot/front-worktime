import 'package:dio/dio.dart';

import '../storage/token_storage.dart';

/// Attaches the bearer token to outgoing requests and reacts to `401`s.
///
/// - On every request it reads the stored access token and, when present,
///   sets `Authorization: Bearer <access_token>`. Endpoints that must remain
///   anonymous (`/auth/register`, `/auth/login`, `/auth/sso/login`) opt out by
///   setting the [skipAuthHeaderKey] flag in `Options.extra`.
/// - On a `401` response it clears local auth material and notifies the app
///   via [onUnauthorized] so the auth state can drop to unauthenticated and
///   the router can redirect to Login. There is no refresh-token flow to
///   attempt, so the request is not retried.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required TokenStorage storage,
    required Future<void> Function() onUnauthorized,
  })  : _storage = storage,
        _onUnauthorized = onUnauthorized;

  final TokenStorage _storage;
  final Future<void> Function() _onUnauthorized;

  /// Set `options.extra[skipAuthHeaderKey] = true` to omit the bearer header.
  static const String skipAuthHeaderKey = 'skipAuthHeader';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final skip = options.extra[skipAuthHeaderKey] == true;
    if (!skip) {
      final token = await _storage.readAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      await _storage.clear();
      await _onUnauthorized();
    }
    handler.next(err);
  }
}
