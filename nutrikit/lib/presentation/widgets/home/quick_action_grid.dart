import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class QuickActionItem {
  const QuickActionItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.gradient,
    this.iconColor,
    this.outlined = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Gradient? gradient;
  final Color? iconColor;
  final bool outlined;
}

class QuickActionGrid extends StatelessWidget {
  const QuickActionGrid({super.key, required this.items});

  final List<QuickActionItem> items;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.35,
      children: items.map(_tile).toList(),
    );
  }

  Widget _tile(QuickActionItem item) {
    final decoration = item.outlined
        ? BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder, width: 1.5),
          )
        : BoxDecoration(
            gradient: item.gradient,
            borderRadius: BorderRadius.circular(16),
          );

    final titleColor = item.outlined ? AppColors.text : Colors.white;
    final subtitleColor =
        item.outlined ? AppColors.muted : Colors.white.withValues(alpha: 0.75);
    final iconBg = item.outlined
        ? (item.iconColor ?? AppColors.primary).withValues(alpha: 0.1)
        : Colors.white.withValues(alpha: 0.2);
    final iconFg = item.outlined ? (item.iconColor ?? AppColors.primary) : Colors.white;

    return Semantics(
      button: true,
      label: item.title,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: decoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, color: iconFg, size: 20),
                ),
                const Spacer(),
                Text(
                  item.title,
                  style: AppTypography.bodyBold.copyWith(
                    color: titleColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  style: AppTypography.caption.copyWith(
                    color: subtitleColor,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
