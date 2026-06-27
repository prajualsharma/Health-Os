import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class ServiceItem {
  const ServiceItem({
    required this.emoji,
    required this.label,
    required this.route,
    required this.bg,
    this.push = false,
  });

  final String emoji;
  final String label;
  final String route;
  final Color bg;

  /// Push onto the root navigator (deep-link) instead of switching tabs.
  final bool push;
}

/// Blinkit-style grid of rounded, colorful icon tiles linking to app sections.
class ServiceIconGrid extends StatelessWidget {
  const ServiceIconGrid({super.key, required this.items});

  final List<ServiceItem> items;

  static const List<ServiceItem> defaults = [
    ServiceItem(
        emoji: '🍱',
        label: 'Order Food',
        route: '/home/food',
        bg: Color(0xFFFFF0E8)),
    ServiceItem(
        emoji: '💪',
        label: 'Gym',
        route: '/home/gym',
        bg: Color(0xFFE8F5FF)),
    ServiceItem(
        emoji: '📋',
        label: 'Meal Plan',
        route: '/home/food?segment=plan',
        bg: Color(0xFFEFFBEF)),
    ServiceItem(
        emoji: '📈',
        label: 'Progress',
        route: '/progress',
        push: true,
        bg: Color(0xFFF3EEFF)),
    ServiceItem(
        emoji: '🛒',
        label: 'Cart',
        route: '/cart',
        push: true,
        bg: Color(0xFFFFF6E0)),
    ServiceItem(
        emoji: '👤',
        label: 'Profile',
        route: '/home/profile',
        bg: Color(0xFFFDEAF0)),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.82,
      children: items.map((item) => _Tile(item: item)).toList(),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.item});

  final ServiceItem item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => item.push ? context.push(item.route) : context.go(item.route),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: item.bg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Center(
              child: Text(item.emoji, style: const TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.caption.copyWith(color: AppColors.text),
          ),
        ],
      ),
    );
  }
}
