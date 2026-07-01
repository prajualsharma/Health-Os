import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

enum MealDeliveryStatus { delivered, upcoming, scheduled }

class MealSummaryTile extends StatelessWidget {
  const MealSummaryTile({
    super.key,
    required this.slot,
    required this.time,
    required this.name,
    required this.calories,
    this.imageUrl,
    this.emoji = '🍽️',
    this.status = MealDeliveryStatus.scheduled,
    this.showStatus = false,
    this.protein,
    this.onTap,
  });

  final String slot;
  final String time;
  final String name;
  final int calories;
  final String? imageUrl;
  final String emoji;
  final MealDeliveryStatus status;
  final bool showStatus;
  final int? protein;
  final VoidCallback? onTap;

  static Color statusColor(MealDeliveryStatus s) => switch (s) {
        MealDeliveryStatus.delivered => AppColors.primary,
        MealDeliveryStatus.upcoming => AppColors.orange,
        MealDeliveryStatus.scheduled => AppColors.muted,
      };

  static String statusLabel(MealDeliveryStatus s) => switch (s) {
        MealDeliveryStatus.delivered => 'Delivered',
        MealDeliveryStatus.upcoming => 'Arriving soon',
        MealDeliveryStatus.scheduled => 'Scheduled',
      };

  @override
  Widget build(BuildContext context) {
    final tile = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1.5),
      ),
      child: Row(
        children: [
          _thumbnail(),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        showStatus
                            ? '$slot · $time'
                            : '$slot  •  $time',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.muted,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (showStatus)
                      Text(
                        statusLabel(status),
                        style: AppTypography.caption.copyWith(
                          color: statusColor(status),
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: AppTypography.bodyBold.copyWith(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '$calories kcal',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (protein != null) ...[
                      const SizedBox(width: 12),
                      Text(
                        '${protein}g protein',
                        style: AppTypography.caption,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (!showStatus)
            Icon(
              status == MealDeliveryStatus.delivered
                  ? Icons.check_circle
                  : Icons.check_circle_outline,
              color: status == MealDeliveryStatus.delivered
                  ? AppColors.primary
                  : AppColors.cardBorder,
              size: 22,
            ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: tile);
    }
    return tile;
  }

  Widget _thumbnail() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 64,
        height: 64,
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _emojiFallback(),
              )
            : _emojiFallback(),
      ),
    );
  }

  Widget _emojiFallback() {
    return ColoredBox(
      color: AppColors.surface,
      child: Center(
        child: Text(emoji, style: const TextStyle(fontSize: 28)),
      ),
    );
  }
}
