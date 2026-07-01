import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../common/app_card.dart';

class AchievementItem {
  const AchievementItem({
    required this.emoji,
    required this.label,
    required this.unlocked,
  });

  final String emoji;
  final String label;
  final bool unlocked;
}

class AchievementGrid extends StatelessWidget {
  const AchievementGrid({
    super.key,
    this.items = const [
      AchievementItem(emoji: '🏆', label: 'First Week', unlocked: true),
      AchievementItem(emoji: '💪', label: 'Strong', unlocked: true),
      AchievementItem(emoji: '🔥', label: 'On Fire', unlocked: true),
      AchievementItem(emoji: '⭐', label: '30 Days', unlocked: false),
    ],
  });

  final List<AchievementItem> items;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Achievements', style: AppTypography.h3),
              const Spacer(),
              Text(
                'View All',
                style: AppTypography.caption.copyWith(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: Opacity(
                    opacity: items[i].unlocked ? 1 : 0.4,
                    child: Column(
                      children: [
                        Text(
                          items[i].emoji,
                          style: TextStyle(
                            fontSize: 28,
                            color: items[i].unlocked
                                ? null
                                : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          items[i].label,
                          style: AppTypography.caption.copyWith(fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
