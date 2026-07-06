import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

/// Base URL of the worktime backend. Override at build/run time with
/// `--dart-define=API_BASE_URL=https://...` — defaults to the local
/// `docker compose` setup documented in the backend's README.
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8080/api/v1',
);

/// Thrown for any non-2xx response. [message] is the backend's
/// `{"error": "..."}` body when present, otherwise a generic fallback.
class ApiException implements Exception {
  const ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;

  @override
  String toString() => message;
}

/// Thin JSON/REST wrapper around [http.Client] for the worktime API.
///
/// Holds the current session's bearer token in memory (set by
/// [AuthController] on login/logout) and attaches it to every request.
/// [onUnauthorized] fires once per 401 response so the caller can force a
/// logout — the backend has no refresh token, so an expired/invalid token
/// always means "log in again".
class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Set by [AuthController] once it exists — kept mutable rather than
  /// constructor-injected to avoid a circular provider dependency (auth
  /// needs this client to log in; this client needs auth to log out).
  void Function()? onUnauthorized;

  String? _token;

  void setToken(String? token) => _token = token;

  Future<dynamic> get(String path, {Map<String, String>? query}) =>
      _send('GET', path, query: query);

  Future<dynamic> post(String path, {Object? body}) =>
      _send('POST', path, body: body);

  Future<dynamic> patch(String path, {Object? body}) =>
      _send('PATCH', path, body: body);

  Future<dynamic> delete(String path) => _send('DELETE', path);

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, String>? query,
    Object? body,
  }) async {
    final uri = Uri.parse('$apiBaseUrl$path')
        .replace(queryParameters: query?.isEmpty == true ? null : query);
    final headers = {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
    final request = http.Request(method, uri)..headers.addAll(headers);
    if (body != null) request.body = jsonEncode(body);

    final streamed = await _client.send(request);
    final response = await http.Response.fromStream(streamed);
    return _decode(response);
  }

  dynamic _decode(http.Response response) {
    final status = response.statusCode;
    final hasBody = response.body.isNotEmpty;
    if (status >= 200 && status < 300) {
      return hasBody ? jsonDecode(response.body) : null;
    }

    var message = 'Request failed ($status)';
    if (hasBody) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['error'] is String) {
          message = decoded['error'] as String;
        }
      } catch (_) {
        // Non-JSON error body — keep the generic message.
      }
    }
    if (status == 401) onUnauthorized?.call();
    throw ApiException(status, message);
  }
}
