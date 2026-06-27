import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Day calorie + macro summary card.
class DayTotalCard extends StatelessWidget {
  const DayTotalCard({
    super.key,
    required this.totalCalories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.onTrack = true,
    this.title = 'Day Total',
    this.addOnCalories,
    this.subtitle,
  });

  final String title;
  final int totalCalories;
  final int protein;
  final int carbs;
  final int fat;
  final bool onTrack;
  final int? addOnCalories;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.green.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.caption),
                    const SizedBox(height: 2),
                    Text(
                      '$totalCalories kcal',
                      style: const TextStyle(
                        color: AppColors.green,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (addOnCalories != null && addOnCalories! > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        '+ $addOnCalories kcal add-ons in cart',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.orange,
                        ),
                      ),
                    ],
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(subtitle!, style: AppTypography.caption),
                    ],
                  ],
                ),
              ),
              if (onTrack)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'On Track ✓',
                    style: TextStyle(
                      color: AppColors.green,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _macroText('${protein}g', 'Protein'),
              const SizedBox(width: 20),
              _macroText('${carbs}g', 'Carbs'),
              const SizedBox(width: 20),
              _macroText('${fat}g', 'Fat'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _macroText(String value, String label) {
    return Row(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTypography.caption),
      ],
    );
  }
}
