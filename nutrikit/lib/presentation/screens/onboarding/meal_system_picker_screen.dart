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

class MealSystemPickerScreen extends StatefulWidget {
  const MealSystemPickerScreen({super.key});

  @override
  State<MealSystemPickerScreen> createState() => _MealSystemPickerScreenState();
}

class _MealSystemPickerScreenState extends State<MealSystemPickerScreen> {
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

  Future<void> _subscribe(MealSystemType type) async {
    await context.read<FoodSubscriptionProvider>().subscribe(type);
    if (!mounted) return;
    context.go('/home/food?segment=tomorrow');
  }

  void _skip() => context.go('/home/food?segment=order');

  @override
  Widget build(BuildContext context) {
    final result = OnboardingStore.instance.result;
    final calories = result?.calorieTarget ?? 1840;
    final protein = result?.proteinTarget ?? 145;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Choose your meal system', style: AppTypography.h1),
              const SizedBox(height: 6),
              Text(
                'Get macro-matched meals delivered — pick 2 or 3 meals per day.',
                style: AppTypography.caption,
              ),
              const SizedBox(height: 8),
              Text(
                'Your target: $calories kcal · ${protein}g protein / day',
                style: AppTypography.bodyBold.copyWith(color: AppColors.green),
              ),
              const SizedBox(height: 24),
              if (_loading)
                const Center(child: CircularProgressIndicator(color: AppColors.green))
              else
                ..._plans.map((p) => _planCard(p)),
              const SizedBox(height: 12),
              AppButton(
                label: 'Skip for now — browse menu',
                variant: ButtonVariant.ghost,
                onPressed: _skip,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _planCard(MealSystemPlan plan) {
    final macrosPerMeal = plan.systemType == MealSystemType.threeMeal
        ? '~${(OnboardingStore.instance.result?.calorieTarget ?? 1840) ~/ 3} kcal / meal'
        : '~${(OnboardingStore.instance.result?.calorieTarget ?? 1840) ~/ 2} kcal / meal';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(plan.name, style: AppTypography.h3),
            const SizedBox(height: 4),
            Text(plan.tagline, style: AppTypography.caption),
            const SizedBox(height: 8),
            Text(macrosPerMeal,
                style: AppTypography.bodyBold.copyWith(color: AppColors.green)),
            const SizedBox(height: 8),
            Text('₹${plan.pricePerMonth}/month',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                )),
            const SizedBox(height: 10),
            ...plan.features.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check, color: AppColors.green, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(f, style: AppTypography.body)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            AppButton(
              label: 'Subscribe (demo)',
              onPressed: () => _subscribe(plan.systemType),
            ),
          ],
        ),
      ),
    );
  }
}
