import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class OnboardingNumberField extends StatelessWidget {
  const OnboardingNumberField({
    super.key,
    required this.controller,
    required this.unitLabel,
    this.hint,
    this.keyboardType = TextInputType.number,
    this.inputFormatters,
    this.onChanged,
  });

  final TextEditingController controller;
  final String unitLabel;
  final String? hint;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              onChanged: onChanged,
              style: AppTypography.h2.copyWith(fontSize: 28),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTypography.h2.copyWith(
                  fontSize: 28,
                  color: AppColors.dim,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
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
