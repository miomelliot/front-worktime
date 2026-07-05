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
    return ColoredBox(
      color: AppColors.canvas,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1040),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Row(
              children: [
                const Expanded(child: _LoginCopy()),
                const SizedBox(width: AppSpacing.xxl),
                Expanded(
                  child: ShadCard(
                    title: const Text('Sign in'),
                    description:
                        const Text('Use a demo role to explore the mock UI.'),
                    child: Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const ShadInput(
                              placeholder: Text('Email'),
                              initialValue: 'ivan.petrov@example.test'),
                          const SizedBox(height: AppSpacing.md),
                          const ShadInput(
                              placeholder: Text('Password'),
                              obscureText: true,
                              initialValue: 'worktime'),
                          const SizedBox(height: AppSpacing.lg),
                          ShadButton(
                            onPressed: () =>
                                _login(ref, context, UserRole.employee),
                            child: const Text('Login as Employee'),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          ShadButton.outline(
                            onPressed: () =>
                                _login(ref, context, UserRole.manager),
                            child: const Text('Login as Manager'),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          ShadButton.outline(
                            onPressed: () =>
                                _login(ref, context, UserRole.admin),
                            child: const Text('Login as Admin'),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          ShadButton.secondary(
                              enabled: false,
                              onPressed: () {},
                              child: const Text('SSO coming soon')),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
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
          'A web-first prototype for time tracking, team presence, calendars, and admin setup.',
          style: TextStyle(fontSize: 18, color: AppColors.muted, height: 1.45),
        ),
      ],
    );
  }
}
