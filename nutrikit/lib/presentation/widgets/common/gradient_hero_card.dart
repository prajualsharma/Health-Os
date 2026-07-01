import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Full-width gradient hero card (home stats, gym burn target, etc.).
class GradientHeroCard extends StatelessWidget {
  const GradientHeroCard({
    super.key,
    required this.child,
    this.gradient,
    this.borderRadius = 24,
    this.padding = const EdgeInsets.all(24),
  });

  final Widget child;
  final Gradient? gradient;
  final double borderRadius;
  final EdgeInsets padding;

  static const orangeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.orange, Color(0xFFF4511E)],
  );

  static const blueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.blue, Color(0xFF0284C7)],
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient ?? AppColors.greenGradient,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: child,
    );
  }
}
