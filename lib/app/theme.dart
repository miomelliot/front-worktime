import 'package:flutter/material.dart';

/// Material 3 theme definitions.
///
/// A single seed color drives both light and dark [ColorScheme]s. Screens
/// should read colors from `Theme.of(context).colorScheme` rather than
/// hard-coding values so the adaptive/dark variants stay consistent.
class AppTheme {
  const AppTheme._();

  static const Color _seed = Color(0xFF2F6FED);

  static ThemeData get light => _base(Brightness.light);
  static ThemeData get dark => _base(Brightness.dark);

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

/// Breakpoints used across the app for adaptive (mobile vs web/desktop)
/// layout decisions.
class AppBreakpoints {
  const AppBreakpoints._();

  /// Below this width we treat the viewport as a compact/mobile layout.
  static const double compact = 600;

  /// At/above this width we can show side rails / master-detail layouts.
  static const double expanded = 1000;

  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < compact;

  static bool isExpanded(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= expanded;
}
