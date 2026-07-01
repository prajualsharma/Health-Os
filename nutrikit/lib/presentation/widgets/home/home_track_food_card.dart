import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class HomeTrackFoodCard extends StatelessWidget {
  const HomeTrackFoodCard({
    super.key,
    required this.calorieTarget,
    required this.proteinPct,
    required this.fatPct,
    required this.carbsPct,
    this.fibrePct = 0,
    this.eatSubtitle,
  });

  final int calorieTarget;
  final double proteinPct;
  final double fatPct;
  final double carbsPct;
  final double fibrePct;
  final String? eatSubtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.orange.withValues(alpha: 0.45),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.restaurant_outlined,
                    color: AppColors.orange,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Track Food', style: AppTypography.h3.copyWith(fontSize: 16)),
                      Text(
                        eatSubtitle ?? 'Eat ${_formatCal(calorieTarget)} Cal',
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ),
                _squareIcon(Icons.add_a_photo_outlined),
                const SizedBox(width: 8),
                _squareIcon(Icons.add_box_outlined),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 56,
                    height: 36,
                    child: Stack(
                      children: [
                        Positioned(left: 0, child: _thumb('🥗')),
                        Positioned(left: 14, child: _thumb('🍗')),
                        Positioned(left: 28, child: _thumb('🥣')),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Browse all your past snaps in one place',
                      style: AppTypography.caption.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios,
                      size: 14, color: AppColors.primaryDark),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(child: _macro('Protein', proteinPct)),
                const SizedBox(width: 8),
                Expanded(child: _macro('Fats', fatPct)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(child: _macro('Carbs', carbsPct)),
                const SizedBox(width: 8),
                Expanded(child: _macro('Fibre', fibrePct)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Material(
            color: AppColors.primarySoft,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
            child: InkWell(
              onTap: () => context.go('/home/food?segment=nutriplan'),
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    const Icon(Icons.restaurant_menu_outlined,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Your AI Diet Plan is Ready!',
                        style: AppTypography.bodyBold.copyWith(
                          color: AppColors.primaryDark,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_forward,
                          color: Colors.white, size: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatCal(int n) =>
      n.toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]},',
          );

  Widget _thumb(String emoji) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 14))),
    );
  }

  Widget _squareIcon(IconData icon) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 18, color: AppColors.muted),
    );
  }

  Widget _macro(String label, double pct) {
    final v = pct.clamp(0, 100);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ${v.round()}%',
          style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: v / 100),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (_, value, child) => LinearProgressIndicator(
              value: value,
              minHeight: 6,
              backgroundColor: AppColors.surface,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}
