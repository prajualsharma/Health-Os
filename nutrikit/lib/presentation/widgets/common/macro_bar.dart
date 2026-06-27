import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class MacroBar extends StatelessWidget {
  const MacroBar({
    super.key,
    required this.label,
    required this.val,
    required this.max,
    required this.color,
  });

  final String label;
  final double val;
  final double max;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final double pct = max <= 0 ? 0 : (val / max).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.dim,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '${val.toInt()}/${max.toInt()}g',
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 5,
            backgroundColor: color.withValues(alpha: 0.18),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
