import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../shared/api/api_client.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/ui/shared_ui.dart';
import '../../auth/domain/app_user.dart';
import '../application/profile_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileControllerProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeader(
          title: 'Профиль',
          description: 'Учётная запись и личные данные.',
        ),
        profile.when(
          loading: () => const LoadingState(label: 'Загружаем профиль'),
          error: (error, stackTrace) => ErrorState(message: '$error'),
          data: (user) => _ProfileContent(user: user),
        ),
      ],
    );
  }
}

class _ProfileContent extends ConsumerStatefulWidget {
  const _ProfileContent({required this.user});

  final AppUser user;

  @override
  ConsumerState<_ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends ConsumerState<_ProfileContent> {
  bool _editing = false;
  bool _saving = false;
  String? _error;

  late final _fullNameController =
      TextEditingController(text: widget.user.name);
  late final _positionController =
      TextEditingController(text: widget.user.title ?? '');
  late final _timezoneController =
      TextEditingController(text: widget.user.timezone);

  @override
  void dispose() {
    _fullNameController.dispose();
    _positionController.dispose();
    _timezoneController.dispose();
    super.dispose();
  }

  void _startEditing() {
    _fullNameController.text = widget.user.name;
    _positionController.text = widget.user.title ?? '';
    _timezoneController.text = widget.user.timezone;
    setState(() {
      _editing = true;
      _error = null;
    });
  }

  Future<void> _save() async {
    final fullName = _fullNameController.text.trim();
    final timezone = _timezoneController.text.trim();
    if (fullName.isEmpty || timezone.isEmpty) {
      setState(() => _error = 'Имя и часовой пояс обязательны.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(profileControllerProvider.notifier).updateProfile(
            fullName: fullName,
            position: _positionController.text.trim(),
            avatarUrl: widget.user.avatarUrl ?? '',
            timezone: timezone,
          );
      if (!mounted) return;
      setState(() => _editing = false);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    // A single column at every width — this screen isn't dense enough to
    // need a responsive two-column split, and it sidesteps nesting a
    // LayoutBuilder around the edit form's text fields (which, combined
    // with AppShell's own top-level LayoutBuilder, is what crashed the Team
    // screen on navigation-away; see team_screen.dart).
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 640),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _IdentityCard(
            user: user,
            editing: _editing,
            saving: _saving,
            error: _error,
            fullNameController: _fullNameController,
            positionController: _positionController,
            timezoneController: _timezoneController,
            onEdit: _startEditing,
            onCancel: () => setState(() {
              _editing = false;
              _error = null;
            }),
            onSave: _save,
          ),
          const SizedBox(height: AppSpacing.lg),
          const _SecurityCard(),
        ],
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({
    required this.user,
    required this.editing,
    required this.saving,
    required this.error,
    required this.fullNameController,
    required this.positionController,
    required this.timezoneController,
    required this.onEdit,
    required this.onCancel,
    required this.onSave,
  });

  final AppUser user;
  final bool editing;
  final bool saving;
  final String? error;
  final TextEditingController fullNameController;
  final TextEditingController positionController;
  final TextEditingController timezoneController;
  final VoidCallback onEdit;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final colors = ShadTheme.of(context).colorScheme;
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InitialsAvatar(name: user.name, size: 56),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: colors.foreground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.email,
                      style:
                          TextStyle(fontSize: 13, color: colors.mutedForeground),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        RoleBadge(role: user.role),
                        ShadBadge.outline(child: Text(_statusLabel(user.status))),
                      ],
                    ),
                  ],
                ),
              ),
              if (!editing)
                ShadButton.outline(
                  leading: const Icon(LucideIcons.pencil, size: 14),
                  onPressed: onEdit,
                  child: const Text('Изменить'),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          if (editing)
            _EditForm(
              fullNameController: fullNameController,
              positionController: positionController,
              timezoneController: timezoneController,
              saving: saving,
              error: error,
              onCancel: onCancel,
              onSave: onSave,
            )
          else
            _ViewFields(user: user),
        ],
      ),
    );
  }
}

class _ViewFields extends StatelessWidget {
  const _ViewFields({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _InfoRow(
          icon: LucideIcons.briefcase,
          label: 'Должность',
          value: (user.title?.isNotEmpty ?? false) ? user.title! : '—',
        ),
        _InfoRow(
          icon: LucideIcons.globe,
          label: 'Часовой пояс',
          value: user.timezone,
        ),
        _InfoRow(
          icon: LucideIcons.mail,
          label: 'Эл. почта',
          value: user.email,
          isLast: true,
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colors = ShadTheme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: isLast
          ? null
          : BoxDecoration(
              border: Border(bottom: BorderSide(color: colors.border)),
            ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: colors.mutedForeground),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: colors.mutedForeground),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditForm extends StatelessWidget {
  const _EditForm({
    required this.fullNameController,
    required this.positionController,
    required this.timezoneController,
    required this.saving,
    required this.error,
    required this.onCancel,
    required this.onSave,
  });

  final TextEditingController fullNameController;
  final TextEditingController positionController;
  final TextEditingController timezoneController;
  final bool saving;
  final String? error;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Полное имя', style: TextStyle(fontSize: 13)),
        const SizedBox(height: AppSpacing.xs),
        ShadInput(controller: fullNameController),
        const SizedBox(height: AppSpacing.md),
        const Text('Должность', style: TextStyle(fontSize: 13)),
        const SizedBox(height: AppSpacing.xs),
        ShadInput(controller: positionController),
        const SizedBox(height: AppSpacing.md),
        const Text('Часовой пояс', style: TextStyle(fontSize: 13)),
        const SizedBox(height: AppSpacing.xs),
        ShadInput(controller: timezoneController),
        if (error != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(error!, style: const TextStyle(color: AppColors.rose, fontSize: 13)),
        ],
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: ShadButton.outline(
                enabled: !saving,
                onPressed: onCancel,
                child: const Text('Отмена'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: ShadButton(
                enabled: !saving,
                onPressed: onSave,
                leading: const Icon(LucideIcons.save, size: 14),
                child: Text(saving ? 'Сохранение…' : 'Сохранить'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SecurityCard extends StatelessWidget {
  const _SecurityCard();

  @override
  Widget build(BuildContext context) {
    final colors = ShadTheme.of(context).colorScheme;
    return DashboardCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          const SectionHeader(
            icon: LucideIcons.shieldCheck,
            title: 'Безопасность',
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Регулярно меняйте пароль, чтобы обезопасить учётную запись.',
                  style: TextStyle(fontSize: 13, color: colors.mutedForeground),
                ),
                const SizedBox(height: AppSpacing.md),
                ShadButton.outline(
                  leading: const Icon(LucideIcons.keyRound, size: 14),
                  onPressed: () => showShadDialog(
                    context: context,
                    builder: (context) => const _ChangePasswordDialog(),
                  ),
                  child: const Text('Сменить пароль'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChangePasswordDialog extends ConsumerStatefulWidget {
  const _ChangePasswordDialog();

  @override
  ConsumerState<_ChangePasswordDialog> createState() =>
      _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<_ChangePasswordDialog> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final current = _currentController.text;
    final next = _newController.text;
    if (current.isEmpty || next.length < 8) {
      setState(() =>
          _error = 'Новый пароль должен быть не короче 8 символов.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(profileControllerProvider.notifier).changePassword(
            currentPassword: current,
            newPassword: next,
          );
      if (mounted) Navigator.of(context).maybePop();
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ShadDialog(
      title: const Text('Сменить пароль'),
      description: const Text('Введите текущий и новый пароль.'),
      actions: [
        ShadButton.outline(
          enabled: !_submitting,
          onPressed: () => Navigator.of(context).maybePop(),
          child: const Text('Отмена'),
        ),
        ShadButton(
          enabled: !_submitting,
          onPressed: _submit,
          child: Text(_submitting ? 'Сохранение…' : 'Сохранить'),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            ShadInput(
              controller: _currentController,
              obscureText: true,
              placeholder: const Text('Текущий пароль'),
            ),
            const SizedBox(height: AppSpacing.md),
            ShadInput(
              controller: _newController,
              obscureText: true,
              placeholder: const Text('Новый пароль'),
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(_error!,
                  style: const TextStyle(color: AppColors.rose, fontSize: 13)),
            ],
          ],
        ),
      ),
    );
  }
}

String _statusLabel(String status) {
  switch (status) {
    case 'active':
      return 'Активен';
    case 'blocked':
      return 'Заблокирован';
    case 'fired':
      return 'Уволен';
    default:
      return status;
  }
}
