import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// A plain [ShadCard] with the page's default padding baked in — the base
/// building block every content card on a dashboard-style page sits on.
class DashboardCard extends StatelessWidget {
  const DashboardCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ShadCard(padding: padding, child: child);
  }
}

/// A small icon on a tinted, rounded backdrop. Reused for card headers and
/// stat tiles so every "icon + label" pairing across the app looks the same.
class IconChip extends StatelessWidget {
  const IconChip({
    super.key,
    required this.icon,
    required this.accent,
    this.size = 36,
  });

  final IconData icon;
  final Color accent;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: size * 0.5, color: accent),
    );
  }
}

/// The header strip shared by every content card: an [IconChip], a title,
/// and an optional trailing action, separated from the body by a hairline.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.icon,
    required this.title,
    this.accent = AppColors.brand,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final Color accent;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = ShadTheme.of(context).colorScheme;
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: Row(
        children: [
          IconChip(icon: icon, accent: accent, size: 28),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: colors.foreground,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
