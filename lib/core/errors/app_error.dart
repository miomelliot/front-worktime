/// Normalized, UI-friendly error type.
///
/// The data layer converts every low-level failure (Dio exceptions, non-2xx
/// responses carrying the backend's `{ "error": string }` body, JSON decode
/// problems) into an [AppError] via `error_mapper.dart`. UI code only ever
/// deals with [AppError], never with raw [DioException]s.
class AppError implements Exception {
  const AppError({
    required this.kind,
    required this.message,
    this.statusCode,
  });

  final AppErrorKind kind;

  /// Human-readable message safe to show to the user. When the backend
  /// returned a body it is the server's `error` string; otherwise a generic
  /// message for the [kind].
  final String message;

  /// HTTP status code when the failure originated from an HTTP response.
  final int? statusCode;

  bool get isUnauthorized => kind == AppErrorKind.unauthorized;

  @override
  String toString() => 'AppError($kind, $statusCode): $message';
}

/// Coarse classification of failures, aligned with the backend's documented
/// error responses. UI can branch on this (e.g. show a "not found" empty
/// state vs a retry button).
enum AppErrorKind {
  /// 400 — invalid json / invalid input / invalid path or query param.
  badRequest,

  /// 401 — missing/invalid token or invalid credentials.
  unauthorized,

  /// 403 — forbidden / inactive user / password auth disabled.
  forbidden,

  /// 404 — not found.
  notFound,

  /// 409 — conflict.
  conflict,

  /// 413 — request body too large.
  payloadTooLarge,

  /// 501 — not implemented (e.g. SSO login in the current MVP).
  notImplemented,

  /// 500 and other 5xx — internal server error.
  server,

  /// Connection timeout / no network / DNS, etc.
  network,

  /// Response could not be parsed into the expected shape.
  parsing,

  /// Anything not otherwise classified.
  unknown,
}
