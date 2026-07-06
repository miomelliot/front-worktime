import 'package:flutter/material.dart' show CircularProgressIndicator;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../shared/api/api_client.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_spacing.dart';
import '../application/auth_controller.dart';
import '../domain/user_role.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit(WidgetRef ref) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Введите почту и пароль.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref
          .read(authControllerProvider.notifier)
          .login(email: email, password: password);
      if (!mounted) return;
      final role = ref.read(authControllerProvider)?.role;
      context.go(role == UserRole.admin ? '/admin' : '/today');
    } on ApiException catch (e) {
      setState(() => _error = e.isUnauthorized
          ? 'Неверная почта или пароль.'
          : e.message);
    } catch (e) {
      setState(() => _error = 'Не удалось подключиться к серверу: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final formCard = ShadCard(
          title: const Text('Вход в систему'),
          description: const Text('Войдите со своей учётной записью Worktime.'),
          child: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ShadInput(
                  controller: _emailController,
                  placeholder: const Text('Эл. почта'),
                  keyboardType: TextInputType.emailAddress,
                  onSubmitted: (_) => _submit(ref),
                ),
                const SizedBox(height: AppSpacing.md),
                ShadInput(
                  controller: _passwordController,
                  placeholder: const Text('Пароль'),
                  obscureText: true,
                  onSubmitted: (_) => _submit(ref),
                ),
                if (_error != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    _error!,
                    style: const TextStyle(color: AppColors.rose, fontSize: 13),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                ShadButton(
                  enabled: !_submitting,
                  onPressed: () => _submit(ref),
                  expands: true,
                  child: _submitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Войти'),
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
      },
    );
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
