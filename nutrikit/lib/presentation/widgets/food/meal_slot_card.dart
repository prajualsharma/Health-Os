import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../common/app_card.dart';

/// Single meal row (slot label, emoji, macros, chevron).
class MealSlotCard extends StatelessWidget {
  const MealSlotCard({
    super.key,
    required this.slot,
    required this.name,
    required this.emoji,
    required this.detailLine,
    this.onTap,
    this.trailing,
  });

  final String slot;
  final String name;
  final String emoji;
  final String detailLine;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(slot.toUpperCase(), style: AppTypography.mealSlot),
                  const SizedBox(height: 2),
                  Text(name, style: AppTypography.bodyBold),
                  const SizedBox(height: 2),
                  Text(detailLine, style: AppTypography.caption),
                ],
              ),
            ),
            trailing ?? const Icon(Icons.chevron_right, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}
