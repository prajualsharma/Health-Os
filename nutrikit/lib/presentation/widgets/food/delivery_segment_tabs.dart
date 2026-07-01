import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../screens/main/food_screen.dart';

/// Swiggy-style tombstone segment tabs: Cafe | Nutri | Recipes.
class DeliverySegmentTabs extends StatelessWidget {
  const DeliverySegmentTabs({
    super.key,
    required this.segment,
    required this.onSegmentChanged,
  });

  final FoodSegment segment;
  final ValueChanged<FoodSegment> onSegmentChanged;

  static const tabs = [
    (FoodSegment.cafe, 'Cafe', '☕'),
    (FoodSegment.nutriplan, 'Nutri', '🥗'),
    (FoodSegment.recipes, 'Recipes', '📖'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 14, 8, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < tabs.length; i++)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: i == 0 ? 0 : 3,
                  right: i == tabs.length - 1 ? 0 : 3,
                ),
                child: _TombstoneTab(
                  label: tabs[i].$2,
                  emoji: tabs[i].$3,
                  segment: tabs[i].$1,
                  selected: segment == tabs[i].$1,
                  onTap: () => onSegmentChanged(tabs[i].$1),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TombstoneTab extends StatelessWidget {
  const _TombstoneTab({
    required this.label,
    required this.emoji,
    required this.segment,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String emoji;
  final FoodSegment segment;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          height: selected ? 80 : 68,
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary
                : Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(20),
              bottom: selected ? Radius.zero : const Radius.circular(4),
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.45),
                      blurRadius: 14,
                      offset: const Offset(0, -2),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              if (selected)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: 6,
                    color: segment == FoodSegment.cafe
                        ? const Color(0xFFF7F8FA)
                        : AppColors.bg,
                  ),
                ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    emoji,
                    style: TextStyle(fontSize: selected ? 22 : 18),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                      fontSize: selected ? 12 : 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
