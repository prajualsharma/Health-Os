import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class OnboardingChipGrid extends StatelessWidget {
  const OnboardingChipGrid({
    super.key,
    required this.options,
    required this.selected,
    required this.onToggle,
    this.singleSelectNoneKey,
  });

  final List<String> options;
  final Set<String> selected;
  final ValueChanged<String> onToggle;
  final String? singleSelectNoneKey;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((label) {
        final isSelected = selected.contains(label);
        return GestureDetector(
          onTap: () => onToggle(label),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primarySoft : AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.cardBorder,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.dim,
                      width: 2,
                    ),
                    color: isSelected ? AppColors.primary : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(Icons.circle, size: 8, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 10),
                Text(label, style: AppTypography.bodyBold.copyWith(fontSize: 14)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
