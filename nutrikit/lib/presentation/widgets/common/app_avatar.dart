import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.initials,
    this.size = 44,
    this.accent = false,
  });

  final String initials;
  final double size;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: accent ? AppColors.green : AppColors.dim,
        borderRadius: BorderRadius.circular(size / 3.5),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: accent ? Colors.white : AppColors.text,
            fontSize: size * 0.32,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
