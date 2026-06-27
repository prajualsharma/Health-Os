import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/recipe.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/calorie_ring.dart';

class RecipeDetailScreen extends StatelessWidget {
  const RecipeDetailScreen({super.key, required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.text,
        title: Text(recipe.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(recipe.emoji, style: const TextStyle(fontSize: 48)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(recipe.name, style: AppTypography.h2),
                          Text(recipe.slot, style: AppTypography.caption),
                          if (recipe.fitsGoal) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.greenGlow,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Fits your goal ✓',
                                style: TextStyle(
                                  color: AppColors.green,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    CalorieRing(
                      pct: 85,
                      size: 72,
                      label: '${recipe.calories}',
                      sub: 'kcal',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _macroRow(),
                const SizedBox(height: 20),
                Text('Ingredients', style: AppTypography.h3),
                const SizedBox(height: 8),
                AppCard(
                  child: Column(
                    children: recipe.ingredients.map(_ingredientRow).toList(),
                  ),
                ),
                if (recipe.steps.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text('Steps', style: AppTypography.h3),
                  const SizedBox(height: 8),
                  ...recipe.steps.asMap().entries.map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            '${e.key + 1}. ${e.value}',
                            style: AppTypography.body,
                          ),
                        ),
                      ),
                ],
                const SizedBox(height: 24),
                AppButton(
                  label: 'Log as eaten (demo)',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${recipe.name} logged (demo)')),
                    );
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _macroRow() {
    return Row(
      children: [
        _macroChip('${recipe.calories}', 'kcal', AppColors.green),
        const SizedBox(width: 10),
        _macroChip('${recipe.protein}g', 'Protein', AppColors.success),
        const SizedBox(width: 10),
        _macroChip('${recipe.carbs}g', 'Carbs', AppColors.accent),
        const SizedBox(width: 10),
        _macroChip('${recipe.fat}g', 'Fat', AppColors.orange),
      ],
    );
  }

  Widget _macroChip(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                )),
            Text(label, style: AppTypography.caption),
          ],
        ),
      ),
    );
  }

  Widget _ingredientRow(RecipeIngredient ing) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(ing.name, style: AppTypography.body)),
          Text(
            '${ing.grams}g',
            style: AppTypography.bodyBold.copyWith(color: AppColors.green),
          ),
        ],
      ),
    );
  }
}
