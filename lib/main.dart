import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

/// Точка входа приложения: поднимает Flutter binding и Riverpod scope.
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: WorktimeApp(),
    ),
  );
}
