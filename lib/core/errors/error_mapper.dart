import 'package:dio/dio.dart';

import 'app_error.dart';

/// Converts low-level exceptions into a normalized [AppError].
///
/// This is the single choke point where transport/decoding failures become
/// UI-facing errors. It understands the backend's common error contract:
///
/// ```json
/// { "error": "string" }
/// ```
class ErrorMapper {
  const ErrorMapper._();

  static AppError map(Object error) {
    if (error is AppError) return error;
    if (error is DioException) return _fromDio(error);
    return AppError(
      kind: AppErrorKind.unknown,
      message: 'Unexpected error: $error',
    );
  }

  static AppError _fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
      case DioExceptionType.connectionError:
        return const AppError(
          kind: AppErrorKind.network,
          message: 'Network problem. Check your connection and try again.',
        );
      case DioExceptionType.cancel:
        return const AppError(
          kind: AppErrorKind.unknown,
          message: 'Request was cancelled.',
        );
      case DioExceptionType.badCertificate:
        return const AppError(
          kind: AppErrorKind.network,
          message: 'Secure connection failed.',
        );
      case DioExceptionType.badResponse:
      case DioExceptionType.unknown:
        final response = e.response;
        if (response != null) {
          return _fromResponse(response);
        }
        return AppError(
          kind: AppErrorKind.network,
          message: e.message ?? 'Network problem.',
        );
    }
  }

  static AppError _fromResponse(Response<dynamic> response) {
    final status = response.statusCode ?? 0;
    final serverMessage = _extractServerMessage(response.data);
    final kind = _kindFromStatus(status);
    return AppError(
      kind: kind,
      statusCode: status,
      message: serverMessage ?? _defaultMessage(kind, status),
    );
  }

  /// Pulls the `error` field out of the backend's error body when present.
  static String? _extractServerMessage(dynamic data) {
    if (data is Map) {
      final value = data['error'];
      if (value is String && value.trim().isNotEmpty) return value;
    }
    if (data is String && data.trim().isNotEmpty) return data;
    return null;
  }

  static AppErrorKind _kindFromStatus(int status) {
    switch (status) {
      case 400:
        return AppErrorKind.badRequest;
      case 401:
        return AppErrorKind.unauthorized;
      case 403:
        return AppErrorKind.forbidden;
      case 404:
        return AppErrorKind.notFound;
      case 409:
        return AppErrorKind.conflict;
      case 413:
        return AppErrorKind.payloadTooLarge;
      case 501:
        return AppErrorKind.notImplemented;
      default:
        if (status >= 500) return AppErrorKind.server;
        return AppErrorKind.unknown;
    }
  }

  static String _defaultMessage(AppErrorKind kind, int status) {
    switch (kind) {
      case AppErrorKind.badRequest:
        return 'Invalid request.';
      case AppErrorKind.unauthorized:
        return 'Your session is invalid or has expired.';
      case AppErrorKind.forbidden:
        return 'You do not have access to this resource.';
      case AppErrorKind.notFound:
        return 'Not found.';
      case AppErrorKind.conflict:
        return 'Conflict with the current state.';
      case AppErrorKind.payloadTooLarge:
        return 'The request is too large.';
      case AppErrorKind.notImplemented:
        return 'This feature is not available.';
      case AppErrorKind.server:
        return 'Server error ($status). Please try again later.';
      case AppErrorKind.network:
      case AppErrorKind.parsing:
      case AppErrorKind.unknown:
        return 'Something went wrong ($status).';
    }
  }
}
