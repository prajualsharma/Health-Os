import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Shared bordered shell for all onboarding text/number inputs.
class OnboardingFieldShell extends StatelessWidget {
  const OnboardingFieldShell({
    super.key,
    required this.child,
    this.borderColor = AppColors.primary,
    this.borderRadius = 14,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
  });

  final Widget child;
  final Color borderColor;
  final double borderRadius;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      padding: padding,
      child: child,
    );
  }
}

/// Strips global [InputDecorationTheme] fill/borders so only the shell shows.
InputDecoration onboardingFieldDecoration({
  String? hintText,
  TextStyle? hintStyle,
  TextStyle? style,
  Widget? suffixIcon,
  EdgeInsetsGeometry contentPadding =
      const EdgeInsets.symmetric(vertical: 14),
}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: hintStyle ??
        (style ?? AppTypography.h2.copyWith(fontSize: 24)).copyWith(
          color: AppColors.dim,
        ),
    suffixIcon: suffixIcon,
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    focusedBorder: InputBorder.none,
    errorBorder: InputBorder.none,
    focusedErrorBorder: InputBorder.none,
    filled: false,
    isDense: true,
    contentPadding: contentPadding,
  );
}

class OnboardingTextField extends StatelessWidget {
  const OnboardingTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.style,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
    this.onChanged,
    this.borderColor = AppColors.primary,
  });

  final TextEditingController controller;
  final String hintText;
  final TextStyle? style;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final fieldStyle = style ?? AppTypography.h2.copyWith(fontSize: 24);
    return OnboardingFieldShell(
      borderColor: borderColor,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        validator: validator,
        onChanged: onChanged,
        style: fieldStyle,
        decoration: onboardingFieldDecoration(
          hintText: hintText,
          style: fieldStyle,
        ),
      ),
    );
  }
}

class OnboardingNumberField extends StatelessWidget {
  const OnboardingNumberField({
    super.key,
    required this.controller,
    required this.unitLabel,
    this.hint,
    this.keyboardType = TextInputType.number,
    this.inputFormatters,
    this.onChanged,
    this.borderColor = AppColors.primary,
  });

  final TextEditingController controller;
  final String unitLabel;
  final String? hint;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final fieldStyle = AppTypography.h2.copyWith(fontSize: 28);
    return OnboardingFieldShell(
      borderColor: borderColor,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              onChanged: onChanged,
              style: fieldStyle,
              decoration: onboardingFieldDecoration(
                hintText: hint,
                style: fieldStyle,
              ),
            ),
          ),
          Text(
            unitLabel,
            style: AppTypography.caption.copyWith(
              fontSize: 16,
              color: AppColors.dim,
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingSearchField extends StatelessWidget {
  const OnboardingSearchField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final fieldStyle = AppTypography.caption.copyWith(fontSize: 14);
    return OnboardingFieldShell(
      borderColor: AppColors.cardBorder,
      borderRadius: 28,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: fieldStyle.copyWith(color: AppColors.text),
        decoration: onboardingFieldDecoration(
          hintText: hintText,
          style: fieldStyle,
          suffixIcon: const Icon(Icons.search, color: AppColors.dim),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
