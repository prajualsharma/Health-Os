import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class PillChip extends StatelessWidget {
  const PillChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.selectedColor,
    this.selectedTextColor,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? selectedColor;
  final Color? selectedTextColor;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? (selectedColor ?? AppColors.primary) : AppColors.card;
    final fg = selected
        ? (selectedTextColor ?? Colors.white)
        : AppColors.muted;
    final border = selected
        ? (selectedColor ?? AppColors.primary)
        : AppColors.cardBorder;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: border, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: fg),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: AppTypography.caption.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
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

/// Horizontally scrollable row of [PillChip] widgets.
class PillChipRow<T> extends StatelessWidget {
  const PillChipRow({
    super.key,
    required this.items,
    required this.labelBuilder,
    required this.selected,
    required this.onSelected,
    this.iconBuilder,
    this.selectedColor,
    this.selectedTextColor,
  });

  final List<T> items;
  final String Function(T) labelBuilder;
  final T selected;
  final ValueChanged<T> onSelected;
  final IconData? Function(T)? iconBuilder;
  final Color? selectedColor;
  final Color? selectedTextColor;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            PillChip(
              label: labelBuilder(items[i]),
              selected: items[i] == selected,
              onTap: () => onSelected(items[i]),
              icon: iconBuilder?.call(items[i]),
              selectedColor: selectedColor,
              selectedTextColor: selectedTextColor,
            ),
          ],
        ],
      ),
    );
  }
}
