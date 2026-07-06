import 'package:flutter/material.dart' show CircularProgressIndicator;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../shared/api/api_client.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_spacing.dart';
import '../application/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit(WidgetRef ref) async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Заполните имя, почту и пароль.');
      return;
    }
    if (password.length < 8) {
      setState(() => _error = 'Пароль должен быть не короче 8 символов.');
      return;
    }
    if (password != confirm) {
      setState(() => _error = 'Пароли не совпадают.');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).register(
            email: email,
            password: password,
            fullName: name,
          );
      if (!mounted) return;
      context.go('/today');
    } on ApiException catch (e) {
      setState(() => _error = e.message);
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
          title: const Text('Регистрация'),
          description: const Text('Создайте учётную запись Worktime.'),
          child: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.lg),
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ShadInput(
                    controller: _nameController,
                    placeholder: const Text('Полное имя'),
                    autofillHints: const [AutofillHints.name],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ShadInput(
                    controller: _emailController,
                    placeholder: const Text('Эл. почта'),
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [
                      AutofillHints.newUsername,
                      AutofillHints.email,
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ShadInput(
                    controller: _passwordController,
                    placeholder: const Text('Пароль (от 8 символов)'),
                    obscureText: true,
                    autofillHints: const [AutofillHints.newPassword],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ShadInput(
                    controller: _confirmController,
                    placeholder: const Text('Повторите пароль'),
                    obscureText: true,
                    autofillHints: const [AutofillHints.newPassword],
                    onSubmitted: (_) => _submit(ref),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      _error!,
                      style:
                          const TextStyle(color: AppColors.rose, fontSize: 13),
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
                        : const Text('Зарегистрироваться'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ShadButton.ghost(
                    enabled: !_submitting,
                    onPressed: () => context.go('/login'),
                    expands: true,
                    child: const Text('Уже есть аккаунт? Войти'),
                  ),
                ],
              ),
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
                            const _RegisterCopy(),
                            const SizedBox(height: AppSpacing.xxl),
                            formCard,
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Expanded(child: _RegisterCopy()),
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

class _RegisterCopy extends StatelessWidget {
  const _RegisterCopy();

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
          'Новые учётные записи создаются с ролью «Сотрудник» — '
          'доступ менеджера или администратора выдаёт администратор позже.',
          style: TextStyle(fontSize: 18, color: AppColors.muted, height: 1.45),
        ),
      ],
    );
  }
}
