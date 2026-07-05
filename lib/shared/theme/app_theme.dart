import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'app_radius.dart';

abstract final class AppTheme {
  static ShadThemeData light = ShadThemeData(
    brightness: Brightness.light,
    colorScheme: const ShadZincColorScheme.light(),
    radius: AppRadius.card,
  );

  static ShadThemeData dark = ShadThemeData(
    brightness: Brightness.dark,
    colorScheme: const ShadZincColorScheme.dark(),
    radius: AppRadius.card,
  );
}
