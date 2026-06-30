import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class OnboardingInfoBanner extends StatelessWidget {
  const OnboardingInfoBanner({
    super.key,
    required this.message,
    this.highlight,
    this.variant = InfoBannerVariant.warm,
  });

  final String message;
  final String? highlight;
  final InfoBannerVariant variant;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (variant) {
      InfoBannerVariant.warm => (AppColors.infoBg, AppColors.infoText),
      InfoBannerVariant.soft => (AppColors.primarySoft, AppColors.primaryDark),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text.rich(
        TextSpan(
          style: AppTypography.caption.copyWith(
            fontSize: 13,
            color: fg,
            height: 1.45,
            fontWeight: FontWeight.w600,
          ),
          children: highlight != null
              ? [
                  TextSpan(text: message),
                  TextSpan(
                    text: highlight,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ]
              : [TextSpan(text: message)],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

enum InfoBannerVariant { warm, soft }
