import 'package:flutter/material.dart';

import '../../../core/theme/app_typography.dart';
import '../../../core/theme/cafe_colors.dart';
import '../../../data/models/dish.dart';

class CafeCategoryTile extends StatelessWidget {
  const CafeCategoryTile({super.key, required this.category});

  final CafeCategoryItem category;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: CafeColors.sectionBg,
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: category.imageUrl.isNotEmpty
              ? Image.network(
                  category.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Center(
                    child: Text(category.emoji,
                        style: const TextStyle(fontSize: 28)),
                  ),
                )
              : Center(
                  child:
                      Text(category.emoji, style: const TextStyle(fontSize: 28)),
                ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 72,
          child: Text(
            category.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.caption.copyWith(
              color: CafeColors.text,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
