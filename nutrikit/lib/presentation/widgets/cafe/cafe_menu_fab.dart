import 'package:flutter/material.dart';

import '../../../core/theme/cafe_colors.dart';

class CafeMenuFab extends StatelessWidget {
  const CafeMenuFab({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 56,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: CafeColors.border, width: 1.5),
            boxShadow: CafeColors.cardShadow,
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.restaurant, size: 18, color: CafeColors.text),
              Text(
                'MENU',
                style: TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.w900,
                  color: CafeColors.text,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
