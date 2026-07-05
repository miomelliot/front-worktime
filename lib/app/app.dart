import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'theme.dart';

/// Root widget of the application.
///
/// Wires the [GoRouter] (exposed via [routerProvider]) into a
/// [MaterialApp.router] with a Material 3 light/dark theme. The router is
/// responsible for auth-based redirects, so this widget stays intentionally
/// thin.
class WorktimeApp extends ConsumerWidget {
  const WorktimeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Worktime',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
