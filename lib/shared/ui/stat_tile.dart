import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'dashboard_card.dart';
import '../theme/app_spacing.dart';

/// A dashboard stat at a glance: icon chip, label, and a big value with an
/// optional suffix. Used for the small overview rows above a screen's main
/// content (today's hours, team headcount, etc.) so every tile lines up
/// without height hacks.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.icon,
    required this.accent,
    required this.title,
    required this.value,
    required this.suffix,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String value;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    final colors = ShadTheme.of(context).colorScheme;
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconChip(icon: icon, accent: accent),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: colors.mutedForeground,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: AppSpacing.xs,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 26,
                  height: 1,
                  fontWeight: FontWeight.w700,
                  color: colors.foreground,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  suffix,
                  style: TextStyle(fontSize: 13, color: colors.mutedForeground),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
