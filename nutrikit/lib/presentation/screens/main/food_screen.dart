import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/cart_store.dart';
import '../../providers/food_subscription_provider.dart';
import 'food_cook_view.dart';
import 'food_order_view.dart';
import 'food_plan_upsell_view.dart';
import 'food_tomorrow_view.dart';

enum FoodSegment { plan, order, cook, tomorrow, addOns }

FoodSegment? foodSegmentFromQuery(String? value) => switch (value) {
      'plan' => FoodSegment.plan,
      'order' => FoodSegment.order,
      'cook' => FoodSegment.cook,
      'tomorrow' => FoodSegment.tomorrow,
      'addons' => FoodSegment.addOns,
      _ => null,
    };

class FoodScreen extends StatefulWidget {
  const FoodScreen({super.key, this.initialSegment});

  final FoodSegment? initialSegment;

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  late FoodSegment _segment;

  @override
  void initState() {
    super.initState();
    _segment = widget.initialSegment ?? FoodSegment.order;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.initialSegment == null) {
      final subscribed = context.read<FoodSubscriptionProvider>().isSubscribed;
      if (subscribed && _segment == FoodSegment.order) {
        _segment = FoodSegment.tomorrow;
      }
    }
  }

  @override
  void didUpdateWidget(covariant FoodScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSegment != null &&
        widget.initialSegment != oldWidget.initialSegment) {
      _segment = widget.initialSegment!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sub = context.watch<FoodSubscriptionProvider>();
    final subscribed = sub.isSubscribed;
    final segments = subscribed
        ? [FoodSegment.tomorrow, FoodSegment.addOns]
        : [FoodSegment.plan, FoodSegment.order, FoodSegment.cook];

    if (!segments.contains(_segment)) {
      _segment = segments.first;
    }

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Food', style: AppTypography.h1),
                      Text(
                        subscribed
                            ? 'Plan meals + order add-ons'
                            : 'Plan, order, or cook to your macros',
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ),
                _cartButton(context),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _segmentBar(segments, subscribed),
          Expanded(child: _segmentBody(subscribed)),
        ],
      ),
    );
  }

  Widget _cartButton(BuildContext context) {
    return AnimatedBuilder(
      animation: CartStore.instance,
      builder: (context, _) {
        final count = CartStore.instance.items.length;
        return IconButton(
          onPressed: () => context.push('/cart'),
          icon: Badge(
            isLabelVisible: count > 0,
            label: Text('$count'),
            child: const Icon(Icons.shopping_bag_outlined, color: AppColors.text),
          ),
        );
      },
    );
  }

  Widget _segmentBar(List<FoodSegment> segments, bool subscribed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: segments.map((s) {
            final selected = s == _segment;
            final label = switch (s) {
              FoodSegment.plan => 'Plan',
              FoodSegment.order => 'Order',
              FoodSegment.cook => 'Cook',
              FoodSegment.tomorrow => 'Tomorrow',
              FoodSegment.addOns => 'Add-ons',
            };
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _segment = s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.greenGlow : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? AppColors.green : AppColors.cardBorder,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: selected ? AppColors.green : AppColors.muted,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _segmentBody(bool subscribed) {
    return switch (_segment) {
      FoodSegment.tomorrow => const FoodTomorrowView(),
      FoodSegment.addOns => const FoodOrderView(isAddOnsContext: true),
      FoodSegment.plan => const FoodPlanUpsellView(),
      FoodSegment.order => const FoodOrderView(),
      FoodSegment.cook => const FoodCookView(),
    };
  }
}
