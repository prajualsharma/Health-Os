import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.highlight = false,
    this.onTap,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsets? padding;
  final bool highlight;
  final VoidCallback? onTap;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: highlight
              ? AppColors.green
              : (borderColor ?? AppColors.cardBorder),
          width: 1.5,
        ),
        boxShadow: highlight
            ? const [
                BoxShadow(
                  color: AppColors.primaryGlow,
                  blurRadius: 24,
                  spreadRadius: 1,
                ),
              ]
            : AppColors.cardShadow,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }
}
