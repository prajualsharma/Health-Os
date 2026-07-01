import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/onboarding_store.dart';
import '../../providers/profile_provider.dart';
import '../../screens/main/food_screen.dart';

class FoodDeliveryHeader extends StatelessWidget {
  const FoodDeliveryHeader({
    super.key,
    required this.segment,
    required this.onSegmentChanged,
    this.eta = '16 mins',
    this.onSearchTap,
  });

  final FoodSegment segment;
  final ValueChanged<FoodSegment> onSegmentChanged;
  final String eta;
  final VoidCallback? onSearchTap;

  static const _headerTop = Color(0xFF1A4F48);
  static const _headerBottom = Color(0xFF123832);

  static const _tabs = [
    (FoodSegment.nutriplan, 'NutriPlan', '🥗'),
    (FoodSegment.cafe, 'Cafe', '☕'),
    (FoodSegment.recipes, 'Recipes', '📖'),
  ];

  @override
  Widget build(BuildContext context) {
    final city = OnboardingStore.instance.data.city;
    final profile = context.watch<ProfileProvider>().profile;
    final planLabel = _planDisplayName(profile?.plan);
    final address = city.isNotEmpty
        ? 'To Home — $city'
        : 'To Home — Flat 401, 4th Floor, set city in profile';

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_headerTop, _headerBottom],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          eta,
                          style: AppTypography.h1.copyWith(
                            color: Colors.white,
                            fontSize: 26,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                address,
                                style: AppTypography.caption.copyWith(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down,
                              size: 18,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _PlanPill(planLabel: planLabel),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < _tabs.length; i++)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: i == 0 ? 0 : 3,
                          right: i == _tabs.length - 1 ? 0 : 3,
                        ),
                        child: _TombstoneTab(
                          label: _tabs[i].$2,
                          emoji: _tabs[i].$3,
                          selected: segment == _tabs[i].$1,
                          onTap: () => onSegmentChanged(_tabs[i].$1),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
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
                      onTap: () {
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
            ),
          ],
        ),
      ),
    );
  }

  static String _planDisplayName(String? plan) {
    if (plan == null || plan.isEmpty) return 'NutriPlan';
    if (plan.toLowerCase().contains('nutriplan')) return 'NutriPlan';
    final parts = plan.split(' ');
    return parts.length > 1 ? parts.sublist(1).join(' ') : plan;
  }

  static String _searchPlaceholder(FoodSegment segment) => switch (segment) {
        FoodSegment.nutriplan => "Search for 'High Protein Bowl'",
        FoodSegment.cafe => "Search for 'Matcha Latte'",
        FoodSegment.recipes => "Search for 'Moong Dal Chilla'",
      };
}

class _PlanPill extends StatelessWidget {
  const _PlanPill({required this.planLabel});

  final String planLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                planLabel,
                style: AppTypography.caption.copyWith(
                  color: AppColors.infoText,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  height: 1.1,
                ),
              ),
              Text(
                'Active',
                style: AppTypography.caption.copyWith(
                  color: AppColors.infoText,
                  fontWeight: FontWeight.w700,
                  fontSize: 9,
                  height: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(width: 6),
          Container(
            width: 28,
            height: 20,
            decoration: BoxDecoration(
              gradient: AppColors.greenGradient,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.eco, color: Colors.white, size: 12),
          ),
        ],
      ),
    );
  }
}

class _TombstoneTab extends StatelessWidget {
  const _TombstoneTab({
    required this.label,
    required this.emoji,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          height: selected ? 78 : 68,
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary
                : Colors.white.withValues(alpha: 0.12),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.45),
                      blurRadius: 14,
                      offset: const Offset(0, -2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                emoji,
                style: TextStyle(fontSize: selected ? 22 : 18),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                  fontSize: selected ? 12 : 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
