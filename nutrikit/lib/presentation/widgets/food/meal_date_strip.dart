import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Horizontal Mon–Sun date picker for meal plans.
class MealDateStrip extends StatelessWidget {
  const MealDateStrip({
    super.key,
    required this.dayLabels,
    required this.dates,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> dayLabels;
  final List<int> dates;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(dayLabels.length, (i) {
          final selected = i == selectedIndex;
          return GestureDetector(
            onTap: () => onSelected(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              width: 48,
              height: 56,
              decoration: BoxDecoration(
                color: selected ? AppColors.greenGlow : AppColors.surface,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: selected ? AppColors.green : AppColors.cardBorder,
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayLabels[i],
                    style: TextStyle(
                      color: selected ? AppColors.green : AppColors.muted,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${dates[i]}',
                    style: TextStyle(
                      color: selected ? AppColors.green : AppColors.text,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
