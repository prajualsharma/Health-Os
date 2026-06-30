import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class OnboardingProgressBar extends StatelessWidget {
  const OnboardingProgressBar({super.key, required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: progress.clamp(0.0, 1.0),
        minHeight: 4,
        backgroundColor: AppColors.cardBorder,
        color: AppColors.primary,
      ),
    );
  }
}
