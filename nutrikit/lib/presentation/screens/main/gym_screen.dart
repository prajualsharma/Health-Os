import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/gym.dart';
import '../../../data/services/mock_data.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/gradient_hero_card.dart';
import 'gym_workout_view.dart';

/// Gym tab: workout plan, partner gyms, and membership plans.
class GymScreen extends StatelessWidget {
  const GymScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    return Column(
      children: [
        _gymHeader(),
        Expanded(
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 16, 20, isWide ? 24 : 96),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isWide ? 640 : 640),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const GymWorkoutView(),
                      const SizedBox(height: 24),
                      const GymPartnersView(),
                      const SizedBox(height: 24),
                      Text('Membership plans', style: AppTypography.h3),
                      const SizedBox(height: 12),
                      ...MockData.gymPlans.map((p) => _PlanCard(plan: p)),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _gymHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: GradientHeroCard.blueGradient,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fitness',
                      style: AppTypography.h1.copyWith(
                        color: Colors.white,
                        fontSize: 26,
                      ),
                    ),
                    Text(
                      'Your personalized journey',
                      style: AppTypography.caption.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.fitness_center,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan});

  final GymPlan plan;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: plan.popular ? AppColors.cardGradient : null,
        color: plan.popular ? null : AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: plan.popular ? AppColors.green : AppColors.cardBorder,
          width: plan.popular ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(plan.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Text(plan.name, style: AppTypography.h3),
              const Spacer(),
              if (plan.popular)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('POPULAR',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      )),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(plan.tagline, style: AppTypography.caption),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('₹${plan.pricePerMonth}',
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w900,
                    fontSize: 26,
                  )),
              Text(' / ${plan.period}', style: AppTypography.caption),
            ],
          ),
          const SizedBox(height: 12),
          ...plan.features.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(Icons.check_circle,
                      color: AppColors.success, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(f, style: AppTypography.body)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          AppButton(
            label: 'Choose ${plan.name}',
            variant:
                plan.popular ? ButtonVariant.primary : ButtonVariant.secondary,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${plan.name} plan selected (demo)')),
              );
            },
          ),
        ],
      ),
    );
  }
}
