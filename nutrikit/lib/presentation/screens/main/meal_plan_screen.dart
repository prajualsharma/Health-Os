import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_typography.dart';
import '../../../data/models/meal.dart';
import '../../../data/models/meal_plan.dart';
import '../../../data/services/api_service.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/error_state.dart';
import '../../widgets/common/shimmer_card.dart';
import '../../widgets/food/day_total_card.dart';
import '../../widgets/food/meal_date_strip.dart';
import '../../widgets/food/meal_slot_card.dart';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _dates = [19, 20, 21, 22, 23, 24, 25];

  int _selectedDay = 0;
  MealPlanData? _data;
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
      final data = await ApiService.instance
          .getMealPlan(DateTime(2026, 6, _dates[_selectedDay]));
      if (!mounted) return;
      setState(() {
        _data = data;
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
    final isWide = MediaQuery.of(context).size.width > 900;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isWide ? 900 : 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Meal Plan', style: AppTypography.h1),
                const SizedBox(height: 16),
                _dateStrip(),
                const SizedBox(height: 18),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _body(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _body() {
    if (_error != null) {
      return SizedBox(
        key: const ValueKey('error'),
        height: 360,
        child: ErrorState(message: _error!, onRetry: _load),
      );
    }
    if (_loading || _data == null) {
      return const ShimmerList(key: ValueKey('loading'), count: 4, height: 90);
    }
    final d = _data!;
    if (d.meals.isEmpty) {
      return EmptyState(
        key: const ValueKey('empty'),
        emoji: '📋',
        title: 'No plan yet',
        subtitle: 'Your AI plan generates daily — check back tomorrow',
        actionLabel: 'Refresh',
        onAction: _load,
      );
    }
    return Column(
      key: const ValueKey('content'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _dayTotal(d),
        const SizedBox(height: 16),
        ...d.meals.map(_mealCard),
        const SizedBox(height: 8),
        AppButton(
          label: 'Order This Plan',
          onPressed: () => context.go('/cart'),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _dateStrip() {
    return MealDateStrip(
      dayLabels: _days,
      dates: _dates,
      selectedIndex: _selectedDay,
      onSelected: (i) {
        setState(() => _selectedDay = i);
        _load();
      },
    );
  }

  Widget _dayTotal(MealPlanData d) {
    return DayTotalCard(
      totalCalories: d.totalCalories,
      protein: d.totalProtein,
      carbs: d.totalCarbs,
      fat: d.totalFat,
      onTrack: d.onTrack,
    );
  }

  Widget _mealCard(Meal meal) {
    return MealSlotCard(
      slot: meal.slot,
      name: meal.name,
      emoji: meal.emoji,
      detailLine:
          '${meal.portion} · ${meal.calories} cal · ${meal.protein}g protein',
      onTap: () => context.push('/meal-detail', extra: meal),
    );
  }
}
