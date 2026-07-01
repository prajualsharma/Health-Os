import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/dish.dart';
import '../../../data/models/order.dart';
import '../../../data/services/api_service.dart';
import '../../providers/cart_store.dart';
import '../../providers/onboarding_store.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/error_state.dart';
import '../../widgets/common/pill_chip.dart';
import '../../widgets/common/shimmer_card.dart';

enum CafeCategory { all, coffee, snacks, detox }

class FoodOrderView extends StatefulWidget {
  const FoodOrderView({super.key, this.isAddOnsContext = false});

  final bool isAddOnsContext;

  @override
  State<FoodOrderView> createState() => _FoodOrderViewState();
}

class _FoodOrderViewState extends State<FoodOrderView> {
  CafeCategory _category = CafeCategory.all;
  List<Dish> _dishes = [];
  bool _loading = true;
  String? _error;

  static const _heroImage =
      'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800&h=320&fit=crop&auto=format';

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
      final dishes = await ApiService.instance
          .getKitchenMenu(addOnsOnly: widget.isAddOnsContext);
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

  List<Dish> get _filtered {
    return switch (_category) {
      CafeCategory.all => _dishes,
      CafeCategory.coffee =>
        _dishes.where((d) => d.category == 'Beverage').toList(),
      CafeCategory.snacks =>
        _dishes.where((d) => d.category == 'Snack').toList(),
      CafeCategory.detox => _dishes
          .where((d) =>
              d.category == 'Beverage' && d.calories < 80 ||
              d.name.toLowerCase().contains('detox') ||
              d.name.toLowerCase().contains('green'))
          .toList(),
    };
  }

  int get _remainingKcal {
    final r = OnboardingStore.instance.result;
    final target = r?.calorieTarget ?? 1500;
    return (target - 1270).clamp(0, 9999);
  }

  void _addToCart(Dish dish) {
    CartStore.instance.add(OrderItem(
      id: dish.id,
      name: dish.name,
      emoji: dish.emoji,
      portion: dish.portion,
      calories: dish.calories,
      price: dish.price,
      type: CartItemType.addOn,
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primary,
        duration: const Duration(milliseconds: 900),
        content: Text('${dish.name} added',
            style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _heroBanner(),
              const SizedBox(height: 12),
              _infoCallout(),
              const SizedBox(height: 14),
              PillChipRow<CafeCategory>(
                items: CafeCategory.values,
                labelBuilder: (c) => switch (c) {
                  CafeCategory.all => 'All',
                  CafeCategory.coffee => 'Coffee',
                  CafeCategory.snacks => 'Snacks',
                  CafeCategory.detox => 'Detox',
                },
                selected: _category,
                onSelected: (c) => setState(() => _category = c),
                selectedColor: AppColors.orange,
                selectedTextColor: Colors.white,
                iconBuilder: (c) => switch (c) {
                  CafeCategory.all => Icons.local_fire_department_outlined,
                  CafeCategory.coffee => Icons.coffee_outlined,
                  CafeCategory.snacks => Icons.shopping_bag_outlined,
                  CafeCategory.detox => Icons.water_drop_outlined,
                },
              ),
              const SizedBox(height: 16),
              Expanded(child: _body()),
            ],
          ),
        ),
        _floatingCart(context),
      ],
    );
  }

  Widget _heroBanner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 140,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              _heroImage,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => ColoredBox(
                color: AppColors.surface,
                child: Center(
                  child: Text('☕', style: const TextStyle(fontSize: 48)),
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppColors.text.withValues(alpha: 0.85),
                    AppColors.text.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.7],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'NUTRICAFE · OPEN NOW',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.orange,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sip smart.\nSnack smarter.',
                    style: AppTypography.h3.copyWith(
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  Text(
                    'Every order adapted to your calorie goal.',
                    style: AppTypography.caption.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCallout() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.orange.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppColors.orange, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTypography.caption.copyWith(height: 1.4),
                children: [
                  const TextSpan(
                    text: 'Your daily budget: ',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(
                    text: '$_remainingKcal kcal left. ',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const TextSpan(
                    text:
                        "We've adapted milk options to fit your NutriPlan.",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body() {
    if (_error != null) {
      return ErrorState(message: _error!, onRetry: _load);
    }
    if (_loading) {
      return const ShimmerList(count: 4, height: 180);
    }
    final dishes = _filtered;
    if (dishes.isEmpty) {
      return const EmptyState(
        emoji: '☕',
        title: 'Nothing here',
        subtitle: 'Try a different category',
      );
    }
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: dishes.length,
      itemBuilder: (_, i) => _cafeCard(dishes[i], i == 0),
    );
  }

  Widget _cafeCard(Dish dish, bool bestseller) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 100,
            width: double.infinity,
            child: Stack(
              children: [
                ColoredBox(
                  color: AppColors.surface,
                  child: Center(
                    child: Text(dish.emoji, style: const TextStyle(fontSize: 40)),
                  ),
                ),
                if (bestseller)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star,
                              size: 10, color: AppColors.accent),
                          const SizedBox(width: 3),
                          Text(
                            'Bestseller',
                            style: AppTypography.caption.copyWith(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      dish.isVeg ? 'Veg' : 'Protein',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dish.name,
                    style: AppTypography.bodyBold.copyWith(fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${dish.portion} · ${dish.kitchenName}',
                    style: AppTypography.caption.copyWith(fontSize: 10),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        '₹${dish.price.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${dish.calories} kcal',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => _addToCart(dish),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: const BoxDecoration(
                            color: AppColors.orange,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _floatingCart(BuildContext context) {
    return AnimatedBuilder(
      animation: CartStore.instance,
      builder: (context, _) {
        final count = CartStore.instance.items.length;
        if (count == 0) return const SizedBox.shrink();
        return Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: GestureDetector(
            onTap: () => context.push('/cart'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.orange,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.orange.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'View Cart',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const Text(
                    'Place Order →',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
