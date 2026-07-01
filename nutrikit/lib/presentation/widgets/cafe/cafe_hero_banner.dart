import 'package:flutter/material.dart';

import '../../../core/theme/app_typography.dart';
import '../../../core/theme/cafe_colors.dart';

class CafeHeroBanner extends StatelessWidget {
  const CafeHeroBanner({super.key});

  String get _timeLabel {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'BREAKFAST TIME';
    if (hour >= 12 && hour < 17) return 'LUNCH TIME';
    if (hour >= 17 && hour < 21) return 'DINNER TIME';
    return 'LATE NIGHT CRAVINGS';
  }

  String get _subtitle {
    final hour = DateTime.now().hour;
    if (hour >= 17 && hour < 21) {
      return 'Wrap up your day with comforting food';
    }
    if (hour >= 21 || hour < 5) {
      return 'Satisfy those midnight hunger pangs';
    }
    return 'Start your day with wholesome bites';
  }

  static const _categories = [
    ('Homely Meals', '🍛',
        'https://images.unsplash.com/photo-1585937421612-70a008296fbe?w=300&h=200&fit=crop'),
    ('Munchies & Quick Bites', '🍟',
        'https://images.unsplash.com/photo-1573080496219-b998a60c8d8a?w=300&h=200&fit=crop'),
    ('Sandwiches & Burgers', '🥪',
        'https://images.unsplash.com/photo-1550317138-10000606a72d?w=300&h=200&fit=crop'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: CafeColors.headerGradient,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _timeLabel,
                  style: AppTypography.h1.copyWith(
                    color: CafeColors.neonGreen.withValues(alpha: 0.9),
                    fontSize: 32,
                    fontStyle: FontStyle.italic,
                    shadows: [
                      Shadow(
                        color: CafeColors.neonGreen.withValues(alpha: 0.5),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _subtitle,
                  style: AppTypography.caption.copyWith(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 130,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: _categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final (label, emoji, url) = _categories[i];
                return _CategoryCard(label: label, emoji: emoji, imageUrl: url);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.label,
    required this.emoji,
    required this.imageUrl,
  });

  final String label;
  final String emoji;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: CafeColors.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 4),
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 11,
                color: CafeColors.text,
              ),
              maxLines: 2,
            ),
          ),
          Expanded(
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (_, _, _) => Center(
                child: Text(emoji, style: const TextStyle(fontSize: 32)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
