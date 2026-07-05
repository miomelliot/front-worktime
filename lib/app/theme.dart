import 'package:flutter/material.dart';

/// Определения Material 3 тем приложения.
///
/// Один seed-цвет порождает светлую и темную [ColorScheme]. Экраны должны
/// брать цвета из `Theme.of(context).colorScheme`, чтобы адаптивные и темные
/// варианты оставались согласованными.
class AppTheme {
  const AppTheme._();

  static const Color _seed = Color(0xFF2F6FED);

  /// Светлая тема приложения.
  static ThemeData get light => _base(Brightness.light);

  /// Темная тема приложения.
  static ThemeData get dark => _base(Brightness.dark);

  /// Собирает базовую Material 3 тему для указанной яркости.
  static ThemeData _base(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: const AppBarTheme(centerTitle: false),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
        ),
      ),
    );
  }
}

/// Breakpoint-значения для адаптивных mobile/web/desktop раскладок.
class AppBreakpoints {
  const AppBreakpoints._();

  /// Ширина, ниже которой интерфейс считается компактным/mobile.
  static const double compact = 600;

  /// Ширина, с которой можно показывать rail/master-detail раскладки.
  static const double expanded = 1000;

  /// Проверяет, что текущая ширина меньше [compact].
  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < compact;

  /// Проверяет, что текущая ширина не меньше [expanded].
  static bool isExpanded(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= expanded;
}
