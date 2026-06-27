import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/dish.dart';
import '../../../data/models/meal.dart';
import '../../../data/models/order.dart';
import '../../../data/services/api_service.dart';
import '../../providers/cart_store.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/error_state.dart';
import '../../widgets/common/shimmer_card.dart';
import '../../widgets/common/status_badge.dart';

class KitchenScreen extends StatefulWidget {
  const KitchenScreen({super.key});

  @override
  State<KitchenScreen> createState() => _KitchenScreenState();
}

class _KitchenScreenState extends State<KitchenScreen> {
  static const _filters = ['All', 'Breakfast', 'Lunch', 'Dinner', 'Snack'];
  String _filter = 'All';

  List<Dish> _dishes = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final dishes = await ApiService.instance.getKitchenMenu();
      if (!mounted) return;
      setState(() {
        _dishes = dishes;
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

  List<Dish> get _filtered => _filter == 'All'
      ? _dishes
      : _dishes.where((d) => d.category == _filter).toList();

  void _addToCart(Dish dish) {
    CartStore.instance.add(OrderItem(
      id: dish.id,
      name: dish.name,
      emoji: dish.emoji,
      portion: 'Standard',
      calories: dish.calories,
      price: dish.price,
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.green,
        duration: const Duration(milliseconds: 900),
        content: Text('${dish.name} added to order',
            style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isWide ? 900 : 640),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kitchen', style: AppTypography.h1),
                const SizedBox(height: 2),
                Text('Portions auto-adjusted to your targets',
                    style: AppTypography.caption),
                const SizedBox(height: 16),
                _filterChips(),
                const SizedBox(height: 18),
                Expanded(child: _body()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _body() {
    if (_error != null) {
      return ErrorState(message: _error!, onRetry: _load);
    }
    if (_loading) {
      return const ShimmerList(count: 5, height: 84);
    }
    final dishes = _filtered;
    if (dishes.isEmpty) {
      return const EmptyState(
        emoji: '🍽️',
        title: 'Nothing here',
        subtitle: 'Try a different filter',
      );
    }
    return ListView.separated(
      itemCount: dishes.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) => _dishCard(dishes[i]),
    );
  }

  Widget _filterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((f) {
          final selected = f == _filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _filter = f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  color: selected ? AppColors.greenGlow : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? AppColors.green : AppColors.cardBorder,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  f,
                  style: TextStyle(
                    color: selected ? AppColors.green : AppColors.muted,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _dishCard(Dish dish) {
    return AppCard(
      onTap: () => context.push('/meal-detail', extra: _toMeal(dish)),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(dish.emoji, style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dish.name, style: AppTypography.bodyBold),
                const SizedBox(height: 2),
                Text('${dish.calories} cal · ${dish.protein}g protein',
                    style: AppTypography.caption),
                const SizedBox(height: 6),
                StatusBadge(status: dish.isVeg ? 'Veg' : 'Non-Veg'),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _addToCart(dish),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.green,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text('+',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Meal _toMeal(Dish dish) => Meal(
        id: dish.id,
        slot: dish.category,
        name: dish.name,
        emoji: dish.emoji,
        subtitle: '${dish.calories} cal',
        calories: dish.calories,
        protein: dish.protein,
        carbs: 40,
        fat: 14,
        portion: '350g',
        isVeg: dish.isVeg,
        price: dish.price,
        ingredients: const [],
      );
}
