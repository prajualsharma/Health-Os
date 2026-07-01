import 'package:flutter/material.dart';

import '../../../core/theme/app_typography.dart';
import '../../../core/theme/cafe_colors.dart';

class CafeFreeDeliveryBanner extends StatelessWidget {
  const CafeFreeDeliveryBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: CafeColors.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: CafeColors.badgeBlueBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delivery_dining,
                color: CafeColors.badgeBlue,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Enjoy FREE Delivery',
                    style: AppTypography.bodyBold.copyWith(fontSize: 13),
                  ),
                  Text(
                    'On orders worth ₹99 or more',
                    style: AppTypography.caption.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
