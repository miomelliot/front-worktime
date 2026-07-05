import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'theme.dart';

/// Корневой виджет приложения.
///
/// Подключает [GoRouter] из [routerProvider] к [MaterialApp.router] и задает
/// Material 3 темы. Редиректы по авторизации живут в роутере, поэтому виджет
/// остается тонкой оболочкой.
class WorktimeApp extends ConsumerWidget {
  /// Создает корневое приложение Worktime.
  const WorktimeApp({super.key});

  /// Собирает [MaterialApp.router] с темой и конфигурацией роутера.
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
