import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_spacing.dart';
import '../application/auth_controller.dart';
import '../domain/user_role.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formCard = ShadCard(
      title: const Text('Вход в систему'),
      description:
          const Text('Выберите демо-роль, чтобы посмотреть прототип.'),
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ShadInput(
                placeholder: Text('Эл. почта'),
                initialValue: 'ivan.petrov@example.test'),
            const SizedBox(height: AppSpacing.md),
            const ShadInput(
                placeholder: Text('Пароль'),
                obscureText: true,
                initialValue: 'worktime'),
            const SizedBox(height: AppSpacing.lg),
            ShadButton(
              onPressed: () => _login(ref, context, UserRole.employee),
              expands: true,
              child: const Text('Войти как сотрудник'),
            ),
            const SizedBox(height: AppSpacing.sm),
            ShadButton.outline(
              onPressed: () => _login(ref, context, UserRole.manager),
              expands: true,
              child: const Text('Войти как менеджер'),
            ),
            const SizedBox(height: AppSpacing.sm),
            ShadButton.outline(
              onPressed: () => _login(ref, context, UserRole.admin),
              expands: true,
              child: const Text('Войти как администратор'),
            ),
            const SizedBox(height: AppSpacing.md),
            ShadButton.secondary(
              enabled: false,
              onPressed: () {},
              expands: true,
              child: const Text('Вход через SSO — скоро'),
            ),
          ],
        ),
      ),
    );
    return ColoredBox(
      color: AppColors.canvas,
      child: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1040),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 720) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _LoginCopy(),
                        const SizedBox(height: AppSpacing.xxl),
                        formCard,
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(child: _LoginCopy()),
                      const SizedBox(width: AppSpacing.xxl),
                      Expanded(child: formCard),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login(
      WidgetRef ref, BuildContext context, UserRole role) async {
    await ref.read(authControllerProvider.notifier).loginAs(role);
    if (!context.mounted) return;
    context.go(role == UserRole.admin ? '/admin' : '/today');
  }
}

class _LoginCopy extends StatelessWidget {
  const _LoginCopy();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Worktime',
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900)),
        SizedBox(height: AppSpacing.md),
        Text(
          'Веб-прототип учёта рабочего времени, статусов команды, '
          'календаря и настроек администратора.',
          style: TextStyle(fontSize: 18, color: AppColors.muted, height: 1.45),
        ),
      ],
    );
  }
}
