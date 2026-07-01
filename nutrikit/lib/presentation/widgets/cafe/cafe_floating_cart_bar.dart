import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/cafe_colors.dart';
import '../../providers/cart_store.dart';

class CafeFloatingCartBar extends StatelessWidget {
  const CafeFloatingCartBar({super.key, this.etaMins = 15});

  final int etaMins;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CartStore.instance,
      builder: (context, _) {
        final items = CartStore.instance.items;
        if (items.isEmpty) return const SizedBox.shrink();
        final first = items.last;
        return Positioned(
          left: 16,
          right: 72,
          bottom: 56,
          child: GestureDetector(
            onTap: () => context.push('/cart?context=cafe'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: CafeColors.accentGreen,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: CafeColors.accentGreen.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(first.emoji,
                          style: const TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'View cart',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${items.length} item${items.length == 1 ? '' : 's'} · $etaMins mins',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
