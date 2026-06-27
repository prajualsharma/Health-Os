import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/auth.dart';
import '../../providers/onboarding_store.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_card.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = OnboardingStore.instance;
    final OnboardingResponse r = store.result ??
        const OnboardingResponse(
          calorieTarget: 1840,
          proteinTarget: 145,
          carbTarget: 180,
          fatTarget: 62,
          timelineWeeks: 10,
          targetWeight: 70,
        );
    final fmt = NumberFormat.decimalPattern();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text('🎉', style: TextStyle(fontSize: 52)),
              const SizedBox(height: 8),
              Text('Your Daily Targets',
                  style: AppTypography.h1, textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text('Personalised from your stats and goal',
                  style: AppTypography.caption, textAlign: TextAlign.center),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppColors.cardGradient,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Text('DAILY CALORIES', style: AppTypography.label),
                    const SizedBox(height: 6),
                    Text(
                      fmt.format(r.calorieTarget),
                      style: const TextStyle(
                        color: AppColors.green,
                        fontSize: 56,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -2.5,
                      ),
                    ),
                    const Text('kcal / day',
                        style: TextStyle(color: AppColors.muted)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _macroCard('${r.proteinTarget}g', 'Protein',
                            AppColors.success),
                        const SizedBox(width: 12),
                        _macroCard(
                            '${r.carbTarget}g', 'Carbs', AppColors.accent),
                        const SizedBox(width: 12),
                        _macroCard('${r.fatTarget}g', 'Fat', AppColors.orange),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Row(
                  children: [
                    const Text('📅', style: TextStyle(fontSize: 26)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Goal timeline', style: AppTypography.bodyBold),
                          const SizedBox(height: 2),
                          Text(
                            'Reach ${r.targetWeight.toStringAsFixed(0)}kg in ~${r.timelineWeeks} weeks',
                            style: AppTypography.caption,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Choose Your Meal System →',
                onPressed: () => context.go('/onboarding/meal-system'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _macroCard(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                  color: color,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                )),
            const SizedBox(height: 2),
            Text(label,
                style:
                    const TextStyle(color: AppColors.muted, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
