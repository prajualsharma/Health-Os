import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

enum InsightBannerVariant { primary, purple, soft }

class InsightBanner extends StatelessWidget {
  const InsightBanner({
    super.key,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
    this.icon = Icons.auto_awesome,
    this.variant = InsightBannerVariant.purple,
  });

  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData icon;
  final InsightBannerVariant variant;

  @override
  Widget build(BuildContext context) {
    return switch (variant) {
      InsightBannerVariant.purple => _gradientBanner(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
          ),
          iconBg: Colors.white24,
          textColor: Colors.white,
        ),
      InsightBannerVariant.primary => _softBanner(
          bg: AppColors.primarySoft,
          border: AppColors.primary.withValues(alpha: 0.25),
          iconColor: AppColors.primary,
        ),
      InsightBannerVariant.soft => _softBanner(
          bg: AppColors.card,
          border: AppColors.cardBorder,
          iconColor: AppColors.primary,
        ),
    };
  }

  Widget _gradientBanner({
    required Gradient gradient,
    required Color iconBg,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: textColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: _content(textColor)),
        ],
      ),
    );
  }

  Widget _softBanner({
    required Color bg,
    required Color border,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(child: _content(AppColors.text)),
        ],
      ),
    );
  }

  Widget _content(Color titleColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.bodyBold.copyWith(
            color: titleColor,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          body,
          style: AppTypography.caption.copyWith(
            color: titleColor.withValues(alpha: 0.85),
            height: 1.4,
          ),
        ),
        if (actionLabel != null) ...[
          const SizedBox(height: 10),
          GestureDetector(
            onTap: onAction,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  actionLabel!,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward, size: 14, color: titleColor),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
