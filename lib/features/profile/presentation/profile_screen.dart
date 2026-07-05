import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../shared/theme/app_spacing.dart';
import '../../../shared/ui/shared_ui.dart';
import '../../auth/application/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider);
    if (user == null) {
      return const EmptyState(
          title: 'Not signed in',
          message: 'Login with a demo role to view a profile.');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeader(
            title: 'Profile', description: 'Current fake session user.'),
        Wrap(
          spacing: AppSpacing.lg,
          runSpacing: AppSpacing.lg,
          children: [
            SizedBox(
              width: 420,
              child: ShadCard(
                title: Text(user.name),
                description: Text(user.email),
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RoleBadge(role: user.role),
                      const SizedBox(height: AppSpacing.md),
                      Text(user.title),
                      Text(user.department,
                          style: const TextStyle(color: Color(0xff667085))),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
