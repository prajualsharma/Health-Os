import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

enum ButtonVariant { primary, secondary, ghost }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.width,
  });

  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isLoading;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null && !isLoading;

    final BoxDecoration decoration;
    final Color contentColor;
    switch (variant) {
      case ButtonVariant.primary:
        decoration = BoxDecoration(
          gradient: AppColors.greenGradient,
          borderRadius: BorderRadius.circular(18),
        );
        contentColor = Colors.white;
        break;
      case ButtonVariant.secondary:
        decoration = BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.cardBorder, width: 1.5),
        );
        contentColor = AppColors.text;
        break;
      case ButtonVariant.ghost:
        decoration = BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.green, width: 1.5),
        );
        contentColor = AppColors.green;
        break;
    }

    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: GestureDetector(
        onTap: enabled ? onPressed : null,
        child: Container(
          width: width ?? double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: decoration,
          alignment: Alignment.center,
          child: isLoading
              ? SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(contentColor),
                  ),
                )
              : Text(
                  label,
                  style: TextStyle(
                    color: contentColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
        ),
      ),
    );
  }
}
