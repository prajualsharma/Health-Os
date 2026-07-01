import 'package:flutter/material.dart';

import '../../../core/theme/app_typography.dart';
import '../../../core/theme/cafe_colors.dart';

class CafeCheckoutBill extends StatelessWidget {
  const CafeCheckoutBill({
    super.key,
    required this.itemsTotal,
    required this.originalTotal,
    required this.deliveryCharge,
    required this.convenienceCharge,
    required this.grandTotal,
    required this.totalSavings,
  });

  final double itemsTotal;
  final double originalTotal;
  final double deliveryCharge;
  final double convenienceCharge;
  final double grandTotal;
  final double totalSavings;

  @override
  Widget build(BuildContext context) {
    final saved = originalTotal - itemsTotal;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CafeColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: CafeColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bill details', style: AppTypography.h3),
          const SizedBox(height: 14),
          _row(
            icon: Icons.receipt_outlined,
            label: 'Items total',
            value: '₹${itemsTotal.toStringAsFixed(0)}',
            strikeValue: saved > 0 ? '₹${originalTotal.toStringAsFixed(0)}' : null,
            badge: saved > 0 ? 'Saved ₹${saved.toStringAsFixed(0)}' : null,
          ),
          const SizedBox(height: 10),
          _row(
            icon: Icons.delivery_dining,
            label: 'Delivery charge',
            value: deliveryCharge == 0 ? 'FREE' : '₹${deliveryCharge.toStringAsFixed(0)}',
            strikeValue: deliveryCharge == 0 ? '₹25' : null,
            valueColor: deliveryCharge == 0 ? CafeColors.badgeBlue : null,
          ),
          const SizedBox(height: 10),
          _row(
            icon: Icons.shopping_bag_outlined,
            label: 'Convenience charge',
            value: '₹${convenienceCharge.toStringAsFixed(0)}',
          ),
          const Divider(height: 24, color: CafeColors.border),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Grand total', style: AppTypography.bodyBold),
              Text(
                '₹${grandTotal.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          if (totalSavings > 0) ...[
            const SizedBox(height: 12),
            CafeSavingsBanner(savings: totalSavings),
          ],
        ],
      ),
    );
  }

  Widget _row({
    required IconData icon,
    required String label,
    required String value,
    String? strikeValue,
    String? badge,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: CafeColors.muted),
        const SizedBox(width: 10),
        Expanded(
          child: Row(
            children: [
              Text(label, style: AppTypography.caption.copyWith(fontSize: 13)),
              if (badge != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: CafeColors.badgeBlueBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      color: CafeColors.badgeBlue,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (strikeValue != null) ...[
          Text(
            strikeValue,
            style: TextStyle(
              fontSize: 12,
              color: CafeColors.dim,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          const SizedBox(width: 6),
        ],
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: valueColor ?? CafeColors.text,
          ),
        ),
      ],
    );
  }
}

class CafeSavingsBanner extends StatelessWidget {
  const CafeSavingsBanner({super.key, required this.savings});

  final double savings;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CafeColors.badgeBlueBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your total savings',
                style: AppTypography.caption.copyWith(
                  color: CafeColors.savingsBlue,
                  fontSize: 12,
                ),
              ),
              Text(
                '₹${savings.toStringAsFixed(0)}',
                style: TextStyle(
                  color: CafeColors.savingsBlue,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          Text(
            'Includes ₹25 savings\nthrough free delivery',
            textAlign: TextAlign.right,
            style: AppTypography.caption.copyWith(
              color: CafeColors.savingsBlue,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
