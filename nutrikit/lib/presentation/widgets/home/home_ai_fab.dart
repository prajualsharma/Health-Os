import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Floating AI assistant button (sparkle) on home.
class HomeAiFab extends StatelessWidget {
  const HomeAiFab({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      shadowColor: AppColors.primary.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: AppColors.greenGradient,
          ),
          child: const Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 14,
                left: 14,
                child: Icon(Icons.auto_awesome, color: Colors.white, size: 14),
              ),
              Positioned(
                bottom: 12,
                right: 12,
                child: Icon(Icons.auto_awesome, color: Colors.white, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
