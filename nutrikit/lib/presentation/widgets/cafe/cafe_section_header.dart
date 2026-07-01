import 'package:flutter/material.dart';

import '../../../core/theme/app_typography.dart';
import '../../../core/theme/cafe_colors.dart';

class CafeSectionHeader extends StatelessWidget {
  const CafeSectionHeader(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.cafeSectionTitle.copyWith(color: CafeColors.text),
      ),
    );
  }
}
