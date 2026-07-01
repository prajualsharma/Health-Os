import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/models.dart';

class OpsSummaryBar extends StatelessWidget {
  const OpsSummaryBar({
    super.key,
    required this.counts,
  });

  final Map<OrderStatus, int> counts;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          _chip('New', counts[OrderStatus.newOrder] ?? 0, AppColors.statusNew),
          const SizedBox(width: 8),
          _chip('In prep',
              (counts[OrderStatus.accepted] ?? 0) +
                  (counts[OrderStatus.preparing] ?? 0),
              AppColors.statusPreparing),
          const SizedBox(width: 8),
          _chip('Ready', counts[OrderStatus.ready] ?? 0, AppColors.statusReady),
        ],
      ),
    );
  }

  Widget _chip(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
