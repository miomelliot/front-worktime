import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Static application configuration.
///
/// Values are supplied at build/run time via `--dart-define` so the same
/// codebase can target different backends without code changes, e.g.:
///
/// ```
/// flutter run --dart-define=API_BASE_URL=https://api.example.com
/// ```
class AppConfig {
  const AppConfig({
    required this.apiBaseUrl,
  });

  /// Base URL including the API version prefix.
  ///
  /// The backend serves everything under `/api/v1`, so all endpoint paths in
  /// the data layer are expressed relative to this (e.g. `/auth/login`).
  final String apiBaseUrl;

  static const String _defaultBaseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8080/api/v1');

  factory AppConfig.fromEnvironment() {
    return const AppConfig(apiBaseUrl: _defaultBaseUrl);
  }
}

/// Provides the resolved [AppConfig] to the rest of the app.
final appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig.fromEnvironment();
});
