import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/recipe.dart';
import '../../../data/services/api_service.dart';
import '../../providers/onboarding_store.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/error_state.dart';
import '../../widgets/common/shimmer_card.dart';
import '../../widgets/food/meal_slot_card.dart';

class FoodCookView extends StatefulWidget {
  const FoodCookView({super.key});

  @override
  State<FoodCookView> createState() => _FoodCookViewState();
}

class _FoodCookViewState extends State<FoodCookView> {
  List<Recipe> _recipes = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final r = OnboardingStore.instance.result;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final recipes = await ApiService.instance.getRecipesForTarget(
        calorieTarget: r?.calorieTarget ?? 1840,
        proteinTarget: r?.proteinTarget ?? 145,
      );
      if (!mounted) return;
      setState(() {
        _recipes = recipes;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = OnboardingStore.instance.result;
    final remaining = (r?.calorieTarget ?? 1840) - 1240;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cook to your macros', style: AppTypography.h3),
          const SizedBox(height: 4),
          Text(
            '~$remaining kcal remaining today · ingredients in grams',
            style: AppTypography.caption,
          ),
          const SizedBox(height: 14),
          Expanded(child: _body()),
        ],
      ),
    );
  }

  Widget _body() {
    if (_error != null) {
      return ErrorState(message: _error!, onRetry: _load);
    }
    if (_loading) {
      return const ShimmerList(count: 4, height: 90);
    }
    if (_recipes.isEmpty) {
      return const EmptyState(
        emoji: '🍳',
        title: 'No recipes yet',
        subtitle: 'Check back after setting your targets',
      );
    }
    return ListView.builder(
      itemCount: _recipes.length,
      itemBuilder: (_, i) => _recipeCard(_recipes[i]),
    );
  }

  Widget _recipeCard(Recipe recipe) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MealSlotCard(
        slot: recipe.slot,
        name: recipe.name,
        emoji: recipe.emoji,
        detailLine:
            '${recipe.calories} cal · ${recipe.protein}g protein · ${recipe.ingredients.length} ingredients',
        onTap: () => context.push('/recipe-detail', extra: recipe),
        trailing: recipe.fitsGoal
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.greenGlow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Fits goal',
                  style: TextStyle(
                    color: AppColors.green,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
