import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/meal_system.dart';
import '../../../data/services/api_service.dart';
import '../../providers/food_subscription_provider.dart';
import '../../providers/onboarding_store.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/food/day_total_card.dart';
import '../../widgets/food/meal_slot_card.dart';

class FoodPlanUpsellView extends StatefulWidget {
  const FoodPlanUpsellView({super.key});

  @override
  State<FoodPlanUpsellView> createState() => _FoodPlanUpsellViewState();
}

class _FoodPlanUpsellViewState extends State<FoodPlanUpsellView> {
  List<MealSystemPlan> _plans = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final plans = await ApiService.instance.getMealSystemPlans();
    if (!mounted) return;
    setState(() {
      _plans = plans;
      _loading = false;
    });
  }

  Future<void> _startPlan(MealSystemType type) async {
    await context.read<FoodSubscriptionProvider>().subscribe(type);
    if (!mounted) return;
    context.go('/home/food?segment=nutriplan');
  }

  @override
  Widget build(BuildContext context) {
    final r = OnboardingStore.instance.result;
    final cal = r?.calorieTarget ?? 1840;
    final protein = r?.proteinTarget ?? 145;
    final carbs = r?.carbTarget ?? 180;
    final fat = r?.fatTarget ?? 62;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.greenGlow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.green.withValues(alpha: 0.4)),
                ),
                child: Text(
                  'Get meals delivered — 2 or 3 meals/day',
                  style: AppTypography.bodyBold.copyWith(color: AppColors.green),
                ),
              ),
              const SizedBox(height: 16),
              DayTotalCard(
                title: 'Your daily target',
                totalCalories: cal,
                protein: protein,
                carbs: carbs,
                fat: fat,
                onTrack: true,
              ),
              const SizedBox(height: 20),
              Text('Meal systems', style: AppTypography.h3),
              const SizedBox(height: 12),
              if (_loading)
                const Center(child: CircularProgressIndicator(color: AppColors.green))
              else
                ..._plans.map(_planCard),
              const SizedBox(height: 16),
              Text('Preview slots', style: AppTypography.h3),
              const SizedBox(height: 10),
              const MealSlotCard(
                slot: 'Breakfast',
                name: 'Protein Oats Bowl',
                emoji: '🥣',
                detailLine: '290g · 380 cal · 28g protein',
              ),
              const MealSlotCard(
                slot: 'Lunch',
                name: 'Grilled Chicken Rice',
                emoji: '🍗',
                detailLine: '420g · 520 cal · 45g protein',
              ),
              const MealSlotCard(
                slot: 'Dinner',
                name: 'Salmon & Quinoa',
                emoji: '🐟',
                detailLine: '380g · 480 cal · 38g protein',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _planCard(MealSystemPlan plan) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(plan.name, style: AppTypography.h3),
            Text(plan.tagline, style: AppTypography.caption),
            const SizedBox(height: 8),
            Text('₹${plan.pricePerMonth}/month',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                )),
            const SizedBox(height: 8),
            Text('Slots: ${plan.slots.join(' · ')}',
                style: AppTypography.body),
            const SizedBox(height: 12),
            AppButton(
              label: 'Start plan',
              onPressed: () => _startPlan(plan.systemType),
            ),
          ],
        ),
      ),
    );
  }
}
