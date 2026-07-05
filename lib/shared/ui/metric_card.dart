import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_colors.dart';

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.caption,
    this.icon,
  });

  final String label;
  final String value;
  final String caption;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      radius: AppRadius.card,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          if (icon != null)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.md),
                color: AppColors.statusNotStartedBg,
              ),
              child:
                  Icon(icon, size: 20, color: AppColors.statusNotStartedText),
            ),
          if (icon != null) const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textMuted)),
                const SizedBox(height: AppSpacing.xs),
                Text(value,
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.w700)),
                const SizedBox(height: AppSpacing.xs),
                Text(caption,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
