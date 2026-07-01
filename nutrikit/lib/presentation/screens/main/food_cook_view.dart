import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/recipe.dart';
import '../../../data/services/api_service.dart';
import '../../providers/onboarding_store.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/error_state.dart';
import '../../widgets/common/pill_chip.dart';
import '../../widgets/common/shimmer_card.dart';

enum RecipeFilter { all, veg, nonVeg, deficit, gain }

class FoodCookView extends StatefulWidget {
  const FoodCookView({super.key});

  @override
  State<FoodCookView> createState() => _FoodCookViewState();
}

class _FoodCookViewState extends State<FoodCookView> {
  List<Recipe> _recipes = [];
  RecipeFilter _filter = RecipeFilter.all;
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

  List<Recipe> get _filtered {
    return switch (_filter) {
      RecipeFilter.all => _recipes,
      RecipeFilter.veg =>
        _recipes.where((r) => r.emoji != '🍗' && r.emoji != '🐟').toList(),
      RecipeFilter.nonVeg =>
        _recipes.where((r) => r.emoji == '🍗' || r.emoji == '🐟').toList(),
      RecipeFilter.deficit =>
        _recipes.where((r) => r.calories < 400).toList(),
      RecipeFilter.gain =>
        _recipes.where((r) => r.calories >= 400).toList(),
    };
  }

  bool _isLocked(Recipe recipe, int index) {
    return !recipe.fitsGoal && index % 3 == 2;
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Text('Recipes', style: AppTypography.h3.copyWith(fontSize: 20)),
              const SizedBox(height: 4),
              Text(
                'Matched to your goals. Free with any NutriPlan.',
                style: AppTypography.caption,
              ),
              const SizedBox(height: 14),
              _pricingNote(),
              const SizedBox(height: 14),
              PillChipRow<RecipeFilter>(
                items: RecipeFilter.values,
                labelBuilder: (f) => switch (f) {
                  RecipeFilter.all => 'All',
                  RecipeFilter.veg => 'Veg',
                  RecipeFilter.nonVeg => 'Non-Veg',
                  RecipeFilter.deficit => 'Calorie Deficit',
                  RecipeFilter.gain => 'Calorie Gain',
                },
                selected: _filter,
                onSelected: (f) => setState(() => _filter = f),
                selectedTextColor: Colors.white,
              ),
              const SizedBox(height: 16),
            ]),
          ),
        ),
        ..._contentSlivers(),
        const SliverPadding(
          padding: EdgeInsets.only(
            bottom: AppConstants.shellScrollBottomPadding,
          ),
        ),
      ],
    );
  }

  List<Widget> _contentSlivers() {
    if (_error != null) {
      return [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: ErrorState(message: _error!, onRetry: _load),
          ),
        ),
      ];
    }
    if (_loading) {
      return [
        const SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: ShimmerList(count: 4, height: 120),
          ),
        ),
      ];
    }
    final recipes = _filtered;
    if (recipes.isEmpty) {
      return [
        const SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: EmptyState(
              emoji: '🍳',
              title: 'No recipes yet',
              subtitle: 'Try a different filter',
            ),
          ),
        ),
      ];
    }
    return [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverList.separated(
          itemCount: recipes.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (_, i) => _recipeCard(recipes[i], i),
        ),
      ),
    ];
  }

  Widget _pricingNote() {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          _pricingRow(
            icon: Icons.check_circle_outline,
            color: AppColors.primary,
            text: 'Free with any NutriPlan subscription',
          ),
          const SizedBox(height: 8),
          _pricingRow(
            icon: Icons.eco_outlined,
            color: AppColors.orange,
            text: 'Buy recipes-only for ₹499/mo',
          ),
        ],
      ),
    );
  }

  Widget _pricingRow({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 12, color: color),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _recipeCard(Recipe recipe, int index) {
    final locked = _isLocked(recipe, index);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 120,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ColoredBox(
                        color: AppColors.surface,
                        child: Center(
                          child: Text(
                            recipe.emoji,
                            style: const TextStyle(fontSize: 40),
                          ),
                        ),
                      ),
                      if (locked)
                        Container(
                          color: Colors.black54,
                          child: const Center(
                            child: Icon(Icons.lock_outline,
                                color: Colors.white70, size: 28),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                recipe.name,
                                style: AppTypography.bodyBold.copyWith(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: locked
                                    ? AppColors.surface
                                    : AppColors.primarySoft,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                locked ? 'Locked' : 'Free',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: locked
                                      ? AppColors.muted
                                      : AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                size: 14, color: AppColors.accent),
                            const SizedBox(width: 4),
                            Text(
                              '4.${8 - (index % 3)}',
                              style: AppTypography.caption.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              ' (${120 + index * 40})',
                              style: AppTypography.caption,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: [
                            _tag(recipe.slot),
                            if (recipe.calories < 400) _tag('Calorie Deficit'),
                            if (recipe.protein >= 25) _tag('High Protein'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              '${recipe.calories} kcal',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${recipe.protein}g protein',
                              style: AppTypography.caption,
                            ),
                            const Spacer(),
                            const Icon(Icons.access_time,
                                size: 14, color: AppColors.muted),
                            const SizedBox(width: 3),
                            Text('15 min', style: AppTypography.caption),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (locked)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Unlock with any NutriPlan subscription'),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Text(
                    'Unlock with NutriPlan · Free',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            )
          else
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => context.push('/recipe-detail', extra: recipe),
                child: const SizedBox(height: 4),
              ),
            ),
        ],
      ),
    );
  }

  Widget _tag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: AppTypography.caption.copyWith(fontSize: 10)),
    );
  }
}
