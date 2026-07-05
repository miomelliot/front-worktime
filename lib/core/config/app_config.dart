import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Статическая конфигурация приложения.
///
/// Значения передаются при сборке/запуске через `--dart-define`, чтобы один
/// код мог работать с разными backend-окружениями:
///
/// ```
/// flutter run --dart-define=API_BASE_URL=https://api.example.com
/// ```
class AppConfig {
  /// Создает конфигурацию с базовым URL API.
  const AppConfig({
    required this.apiBaseUrl,
  });

  /// Базовый URL вместе с префиксом версии API.
  ///
  /// Backend обслуживает API под `/api/v1`, поэтому data layer использует
  /// относительные пути вроде `/auth/login`.
  final String apiBaseUrl;

  static const String _defaultBaseUrl = String.fromEnvironment('API_BASE_URL',
      defaultValue: 'http://localhost:8080/api/v1');

  /// Читает конфигурацию из compile-time environment.
  factory AppConfig.fromEnvironment() {
    return const AppConfig(apiBaseUrl: _defaultBaseUrl);
  }
}

/// Предоставляет разрешенную [AppConfig] всему приложению.
final appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig.fromEnvironment();
});
