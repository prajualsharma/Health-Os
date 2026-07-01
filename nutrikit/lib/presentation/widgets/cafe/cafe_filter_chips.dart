import 'package:flutter/material.dart';

import '../../../core/theme/app_typography.dart';
import '../../../core/theme/cafe_colors.dart';
import 'cafe_veg_icon.dart';

enum CafeFilter { none, veg, nonVeg, highlyReordered, chefsChoice }

class CafeFilterChips extends StatelessWidget {
  const CafeFilterChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final CafeFilter selected;
  final ValueChanged<CafeFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _chip(
            label: 'Veg',
            filter: CafeFilter.veg,
            bg: CafeColors.sectionBg,
            leading: const CafeVegIcon(isVeg: true, size: 12),
          ),
          const SizedBox(width: 8),
          _chip(
            label: 'Non-veg',
            filter: CafeFilter.nonVeg,
            bg: const Color(0xFFFFF3E0),
            leading: const CafeVegIcon(isVeg: false, size: 12),
          ),
          const SizedBox(width: 8),
          _chip(
            label: 'Highly Reordered',
            filter: CafeFilter.highlyReordered,
            bg: CafeColors.sectionBg,
            leading: Icon(Icons.replay, size: 14, color: CafeColors.accentGreen),
          ),
          const SizedBox(width: 8),
          _chip(
            label: "Chef's Choice",
            filter: CafeFilter.chefsChoice,
            bg: const Color(0xFFE0F7FA),
            leading: Icon(Icons.restaurant, size: 14, color: Colors.teal),
          ),
        ],
      ),
    );
  }

  Widget _chip({
    required String label,
    required CafeFilter filter,
    required Color bg,
    required Widget leading,
  }) {
    final isSelected = selected == filter;
    return GestureDetector(
      onTap: () => onSelected(isSelected ? CafeFilter.none : filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? CafeColors.accentGreen.withValues(alpha: 0.15) : bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? CafeColors.accentGreen : CafeColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            leading,
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: CafeColors.text,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
