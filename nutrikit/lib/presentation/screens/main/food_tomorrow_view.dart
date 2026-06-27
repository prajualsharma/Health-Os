import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/dish.dart';
import '../../../data/models/order.dart';
import '../../../data/services/api_service.dart';
import '../../providers/cart_store.dart';
import '../../providers/food_subscription_provider.dart';
import '../../providers/onboarding_store.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/food/day_total_card.dart';
import '../../widgets/food/meal_date_strip.dart';

class FoodTomorrowView extends StatefulWidget {
  const FoodTomorrowView({super.key});

  @override
  State<FoodTomorrowView> createState() => _FoodTomorrowViewState();
}

class _FoodTomorrowViewState extends State<FoodTomorrowView> {
  static const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  late final DateTime _base = DateTime.now();
  int _selectedIndex = 1;
  Map<String, List<Dish>> _options = {};
  final Map<String, Dish?> _selections = {};
  bool _loading = true;

  List<int> get _dates => List.generate(
        7,
        (i) => _base.add(Duration(days: i - _base.weekday + 1)).day,
      );

  DateTime get _selectedDate =>
      _base.add(Duration(days: _selectedIndex - _base.weekday + 1));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (!mounted) return;
    final sub = context.read<FoodSubscriptionProvider>();
    final slots = sub.activeSlots;
    setState(() => _loading = true);
    final options = await ApiService.instance.getTomorrowOptions(
      date: _selectedDate,
      slots: slots,
    );
    if (!mounted) return;
    setState(() {
      _options = options;
      _loading = false;
      for (final s in slots) {
        _selections.putIfAbsent(s, () => options[s]?.firstOrNull);
      }
    });
  }

  int get _planCalories => _selections.values
      .whereType<Dish>()
      .fold(0, (sum, d) => sum + d.calories);

  int get _planProtein => _selections.values
      .whereType<Dish>()
      .fold(0, (sum, d) => sum + d.protein);

  int get _addOnCalories => CartStore.instance.items
      .where((i) => i.type == CartItemType.addOn)
      .fold(0, (sum, i) => sum + i.calories);

  @override
  Widget build(BuildContext context) {
    final result = OnboardingStore.instance.result;
    final targetCal = result?.calorieTarget ?? 1840;
    final sub = context.watch<FoodSubscriptionProvider>();

    return AnimatedBuilder(
      animation: CartStore.instance,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Tomorrow's delivery", style: AppTypography.h3),
                  const SizedBox(height: 12),
                  MealDateStrip(
                    dayLabels: _dayLabels,
                    dates: _dates,
                    selectedIndex: _selectedIndex,
                    onSelected: (i) {
                      setState(() => _selectedIndex = i);
                      _load();
                    },
                  ),
                  const SizedBox(height: 16),
                  DayTotalCard(
                    title: 'Day Total',
                    totalCalories: _planCalories,
                    protein: _planProtein,
                    carbs: (_planCalories * 0.45 / 4).round(),
                    fat: (_planCalories * 0.25 / 9).round(),
                    onTrack: _planCalories <= targetCal + 100,
                    addOnCalories:
                        _addOnCalories > 0 ? _addOnCalories : null,
                    subtitle: 'Plan meals + add-ons tracked separately',
                  ),
                  const SizedBox(height: 20),
                  if (_loading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(color: AppColors.green),
                      ),
                    )
                  else
                    ...sub.activeSlots.map(_slotSection),
                  const SizedBox(height: 8),
                  AppButton(
                    label: "Confirm tomorrow's meals",
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tomorrow\'s meals confirmed (demo)'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _slotSection(String slot) {
    final dishes = _options[slot] ?? [];
    final selected = _selections[slot];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$slot — pick 1 of ${dishes.length}', style: AppTypography.h3),
        const SizedBox(height: 10),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: dishes.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _optionCard(slot, dishes[i], selected),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _optionCard(String slot, Dish dish, Dish? selected) {
    final isSelected = selected?.id == dish.id;
    return GestureDetector(
      onTap: () => _showDetail(slot, dish),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 160,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.greenGlow : AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.green : AppColors.cardBorder,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dish.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 8),
            Text(dish.name,
                style: AppTypography.bodyBold,
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            const Spacer(),
            Text(dish.kitchenName,
                style: AppTypography.caption, maxLines: 1),
            Text('${dish.portion} · ${dish.calories} cal',
                style: AppTypography.caption),
          ],
        ),
      ),
    );
  }

  void _showDetail(String slot, Dish dish) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${dish.emoji} ${dish.name}', style: AppTypography.h3),
            const SizedBox(height: 6),
            Text('${dish.kitchenName} · ⭐ ${dish.rating}',
                style: AppTypography.caption),
            Text(
              '${dish.portion} · ${dish.calories} cal · ${dish.protein}g protein',
              style: AppTypography.body,
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'Select for tomorrow',
              onPressed: () {
                setState(() => _selections[slot] = dish);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}

extension _FirstOrNull<E> on List<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
