import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/meal.dart';
import '../../../data/models/order.dart';
import '../../providers/cart_store.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_card.dart';

class MealDetailScreen extends StatelessWidget {
  const MealDetailScreen({super.key, required this.meal});

  final Meal meal;

  void _addToOrder(BuildContext context) {
    CartStore.instance.add(OrderItem(
      id: meal.id,
      name: meal.name,
      emoji: meal.emoji,
      portion: meal.portion,
      calories: meal.calories,
      price: meal.price,
    ));
    context.go('/cart');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: false,
            floating: false,
            backgroundColor: AppColors.bg,
            leading: const BackButton(color: AppColors.text),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFF0EB), AppColors.card],
                  ),
                ),
                child: Center(
                  child: Text(meal.emoji, style: const TextStyle(fontSize: 90)),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(meal.name, style: AppTypography.h2),
                      ),
                      _vegBadge(),
                    ],
                  ),
                  const SizedBox(height: 6),
                  RichText(
                    text: TextSpan(
                      style: AppTypography.body.copyWith(color: AppColors.muted),
                      children: [
                        const TextSpan(text: 'Your portion: '),
                        TextSpan(
                          text: meal.portion,
                          style: const TextStyle(
                            color: AppColors.green,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const TextSpan(
                            text: ' — personalised to your targets'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      _macroChip('${meal.calories}', 'kcal', AppColors.green),
                      const SizedBox(width: 10),
                      _macroChip('${meal.protein}g', 'Protein',
                          AppColors.accent),
                      const SizedBox(width: 10),
                      _macroChip('${meal.carbs}g', 'Carbs', AppColors.blue),
                      const SizedBox(width: 10),
                      _macroChip('${meal.fat}g', 'Fat', AppColors.orange),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('Ingredients', style: AppTypography.h3),
                  const SizedBox(height: 12),
                  AppCard(
                    child: Column(
                      children: [
                        for (int i = 0; i < meal.ingredients.length; i++) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(meal.ingredients[i].name,
                                  style: AppTypography.body),
                              Text(meal.ingredients[i].weight,
                                  style: AppTypography.caption),
                            ],
                          ),
                          if (i != meal.ingredients.length - 1)
                            const Divider(
                                color: AppColors.cardBorder, height: 20),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  AppButton(
                    label: 'Add to Order',
                    onPressed: () => _addToOrder(context),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _vegBadge() {
    final veg = meal.isVeg;
    final color = veg ? AppColors.success : AppColors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        veg ? 'Veg' : 'Non-Veg',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _macroChip(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                )),
            const SizedBox(height: 2),
            Text(label,
                style:
                    const TextStyle(color: AppColors.muted, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
