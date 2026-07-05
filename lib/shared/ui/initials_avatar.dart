import 'package:flutter/widgets.dart';

import '../theme/app_colors.dart';

/// A round avatar showing a person's initials on a tinted backdrop. The tint
/// is picked deterministically from the name so the same person always gets
/// the same color, and different people are easy to tell apart at a glance.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({super.key, required this.name, this.size = 40});

  final String name;
  final double size;

  static const _palette = [
    AppColors.brand,
    AppColors.teal,
    AppColors.violet,
    AppColors.amber,
    AppColors.rose,
    AppColors.statusStoppedText,
  ];

  @override
  Widget build(BuildContext context) {
    final accent = _palette[name.hashCode.abs() % _palette.length];
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        _initials(name),
        style: TextStyle(
          color: accent,
          fontSize: size * 0.35,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

String _initials(String name) {
  final parts =
      name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) {
    return parts.first.characters.take(2).toString().toUpperCase();
  }
  return '${parts.first.characters.first}${parts.last.characters.first}'
      .toUpperCase();
}
