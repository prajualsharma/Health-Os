import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../screens/main/food_screen.dart';

/// Shared search bar + bookmark row below segment tabs.
class DeliveryHeaderSearchRow extends StatelessWidget {
  const DeliveryHeaderSearchRow({
    super.key,
    required this.segment,
    this.onSearchTap,
    this.onBookmarkTap,
  });

  final FoodSegment segment;
  final VoidCallback? onSearchTap;
  final VoidCallback? onBookmarkTap;

  static const padding = EdgeInsets.fromLTRB(16, 10, 16, 14);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onSearchTap,
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _searchPlaceholder(segment),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.dim,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.search, color: AppColors.muted, size: 22),
                    Container(
                      width: 1,
                      height: 22,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      color: AppColors.cardBorder,
                    ),
                    Icon(
                      Icons.edit_note_outlined,
                      color: AppColors.muted,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: onBookmarkTap ??
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Saved items coming soon')),
                    );
                  },
              borderRadius: BorderRadius.circular(12),
              child: const SizedBox(
                width: 48,
                height: 48,
                child: Icon(
                  Icons.bookmark_border,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _searchPlaceholder(FoodSegment segment) => switch (segment) {
        FoodSegment.nutriplan => "Search for 'High Protein Bowl'",
        FoodSegment.cafe => "Search for 'Matcha Latte'",
        FoodSegment.recipes => "Search for 'Moong Dal Chilla'",
      };
}
