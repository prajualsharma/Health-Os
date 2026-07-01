import 'package:flutter/material.dart';

import '../../../core/theme/app_typography.dart';
import '../../../core/theme/cafe_colors.dart';
import '../../../data/models/dish.dart';
import '../../../data/models/order.dart';
import '../../providers/cart_store.dart';
import 'cafe_add_button.dart';
import 'cafe_veg_icon.dart';

class CafeProductCard extends StatelessWidget {
  const CafeProductCard({
    super.key,
    required this.dish,
    required this.onAdd,
    this.compact = false,
    this.width,
  });

  final Dish dish;
  final VoidCallback onAdd;
  final bool compact;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CartStore.instance,
      builder: (context, _) {
        final qty = CartStore.instance.quantityFor(dish.id);
        return SizedBox(
          width: width ?? (compact ? 150 : null),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _imageArea(qty),
              const SizedBox(height: 8),
              _metaRow(),
              const SizedBox(height: 4),
              Text(
                dish.name,
                style: AppTypography.bodyBold.copyWith(
                  fontSize: compact ? 12 : 13,
                  color: CafeColors.text,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (!compact && dish.isHighlyReordered) ...[
                const SizedBox(height: 4),
                _reorderBar(),
              ],
              if (!compact && dish.description.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  dish.description,
                  style: AppTypography.caption.copyWith(
                    fontSize: 10,
                    color: CafeColors.muted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 4),
              _priceRow(),
            ],
          ),
        );
      },
    );
  }

  Widget _imageArea(int qty) {
    final h = compact ? 120.0 : 140.0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: h,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _image(),
            if (dish.isMostLoved)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: CafeColors.mostLovedRed,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.favorite, color: Colors.white, size: 10),
                      SizedBox(width: 2),
                      Text(
                        'Most Loved',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (dish.isPreviouslyBought)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: CafeColors.badgeBlueBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Previously Bought',
                    style: TextStyle(
                      color: CafeColors.badgeBlue,
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: 8,
              right: 8,
              child: qty > 0
                  ? CafeQuantityStepper(
                      quantity: qty,
                      onDecrement: () => CartStore.instance.decrement(dish.id),
                      onIncrement: onAdd,
                    )
                  : CafeAddButton(onTap: onAdd, showCustomise: !compact),
            ),
          ],
        ),
      ),
    );
  }

  Widget _image() {
    if (dish.imageUrl.isNotEmpty) {
      return Image.network(
        dish.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _emojiFallback(),
      );
    }
    return _emojiFallback();
  }

  Widget _emojiFallback() {
    return ColoredBox(
      color: CafeColors.sectionBg,
      child: Center(
        child: Text(dish.emoji, style: const TextStyle(fontSize: 40)),
      ),
    );
  }

  Widget _metaRow() {
    return Row(
      children: [
        CafeVegIcon(isVeg: dish.isVeg, size: 12),
        const SizedBox(width: 4),
        _pill(Icons.access_time, '${dish.prepTimeMins} mins'),
        const SizedBox(width: 4),
        Flexible(child: _pill(null, dish.portion)),
      ],
    );
  }

  Widget _pill(IconData? icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: CafeColors.badgeBlue.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 9, color: CafeColors.badgeBlue),
            const SizedBox(width: 2),
          ],
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 9,
                color: CafeColors.muted,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _reorderBar() {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: 0.72,
              minHeight: 3,
              backgroundColor: CafeColors.border,
              color: CafeColors.accentGreen,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'Highly reordered',
          style: AppTypography.caption.copyWith(fontSize: 9),
        ),
      ],
    );
  }

  Widget _priceRow() {
    return Row(
      children: [
        if (dish.discountPercent != null) ...[
          Text(
            '${dish.discountPercent}% OFF',
            style: TextStyle(
              color: CafeColors.badgeBlue,
              fontSize: compact ? 9 : 10,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 4),
        ],
        Text(
          '₹${dish.price.toStringAsFixed(0)}',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: compact ? 12 : 14,
            color: CafeColors.text,
          ),
        ),
        if (dish.originalPrice > dish.price) ...[
          const SizedBox(width: 4),
          Text(
            '₹${dish.originalPrice.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: compact ? 10 : 11,
              color: CafeColors.dim,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      ],
    );
  }

  static OrderItem toOrderItem(Dish dish) => OrderItem(
        id: dish.id,
        name: dish.name,
        emoji: dish.emoji,
        portion: dish.portion,
        calories: dish.calories,
        price: dish.price,
        type: CartItemType.addOn,
      );
}
