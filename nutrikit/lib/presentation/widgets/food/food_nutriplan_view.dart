import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/dashboard.dart';
import '../../../data/models/meal_system.dart';
import '../../../data/services/api_service.dart';
import '../../providers/food_subscription_provider.dart';
import '../../providers/onboarding_store.dart';
import '../../screens/main/food_tomorrow_view.dart';
import '../common/app_button.dart';
import '../common/insight_banner.dart';
import '../common/meal_summary_tile.dart';
import '../common/section_header.dart';
import '../common/shimmer_card.dart';

class FoodNutriplanView extends StatefulWidget {
  const FoodNutriplanView({super.key});

  @override
  State<FoodNutriplanView> createState() => _FoodNutriplanViewState();
}

class _FoodNutriplanViewState extends State<FoodNutriplanView> {
  List<MealSystemPlan> _plans = [];
  DashboardData? _dashboard;
  int _activePlan = 0;
  bool _loading = true;

  static const _mealTimes = {
    'Breakfast': '8:00 AM',
    'Lunch': '1:00 PM',
    'Dinner': '8:00 PM',
    'Snack': '4:00 PM',
  };

  static const _planColors = [
    AppColors.primary,
    AppColors.orange,
    AppColors.blue,
  ];

  static const _planTags = ['Most Popular', 'High Protein', 'Best for beginners'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final plans = await ApiService.instance.getMealSystemPlans();
      DashboardData? dash;
      try {
        dash = await ApiService.instance.getDashboard();
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        _plans = plans;
        _dashboard = dash;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _subscribe(MealSystemType type) async {
    await context.read<FoodSubscriptionProvider>().subscribe(type);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('NutriPlan activated!')),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final subscribed = context.watch<FoodSubscriptionProvider>().isSubscribed;
    if (subscribed) {
      return const FoodTomorrowView();
    }

    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: ShimmerList(count: 4, height: 100),
      );
    }

    final r = OnboardingStore.instance.result;
    final calTarget = r?.calorieTarget ?? _dashboard?.calorieTarget ?? 1500;
    final consumed = _dashboard?.caloriesConsumed ?? 0;
    final pct = calTarget <= 0 ? 0.0 : (consumed / calTarget).clamp(0.0, 1.0);
    final remaining = (calTarget - consumed).clamp(0, 99999);
    final totalProtein = _dashboard?.proteinConsumed ?? r?.proteinTarget ?? 0;
    final meals = _dashboard?.meals ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _aiBanner(calTarget, consumed, pct, remaining, totalProtein, r),
          const SizedBox(height: 24),
          if (meals.isNotEmpty) ...[
            SectionHeader(
              title: "Today's Meals",
              trailingLabel: 'View week →',
            ),
            const SizedBox(height: 12),
            ...meals.asMap().entries.map((e) {
              final status = switch (e.key) {
                0 => MealDeliveryStatus.delivered,
                1 => MealDeliveryStatus.upcoming,
                _ => MealDeliveryStatus.scheduled,
              };
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: MealSummaryTile(
                  slot: e.value.slot,
                  time: _mealTimes[e.value.slot] ?? e.value.subtitle,
                  name: e.value.name,
                  calories: e.value.calories,
                  emoji: e.value.emoji,
                  status: status,
                  showStatus: true,
                  protein: e.value.protein,
                ),
              );
            }),
            const SizedBox(height: 24),
          ],
          SectionHeader(
            title: 'Choose a Plan',
            trailingLabel: '30-day rolling',
          ),
          const SizedBox(height: 12),
          if (_plans.isEmpty)
            Text('No plans available', style: AppTypography.caption)
          else ...[
            SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _plans.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (_, i) => _planCard(_plans[i], i),
              ),
            ),
            const SizedBox(height: 16),
            AppButton(
              label:
                  'Subscribe to ${_plans[_activePlan].name} — ₹${_plans[_activePlan].pricePerMonth}/mo',
              onPressed: () => _subscribe(_plans[_activePlan].systemType),
            ),
          ],
          const SizedBox(height: 20),
          InsightBanner(
            title: 'AI says: Add $remaining kcal tonight',
            body:
                "You're $remaining kcal short of today's target. Your dinner can be adjusted to fit your plan.",
            variant: InsightBannerVariant.soft,
            icon: Icons.bolt_outlined,
          ),
        ],
      ),
    );
  }

  Widget _aiBanner(
    int calTarget,
    int consumed,
    double pct,
    int remaining,
    int totalProtein,
    dynamic r,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A2410), Color(0xFF0F1A08)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'AI NUTRITION ENGINE',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Your plan is\ndialed in.',
                      style: AppTypography.h2.copyWith(
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'NutriPlan · Get started today',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$consumed',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    '/ $calTarget kcal today',
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(pct * 100).round()}% of daily goal',
                style: AppTypography.caption,
              ),
              Text(
                '$remaining kcal remaining',
                style: AppTypography.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _macroPill('Protein', '${totalProtein}g', AppColors.orange),
              _macroPill('Carbs', '${r?.carbTarget ?? 164}g', AppColors.blue),
              _macroPill('Fat', '${r?.fatTarget ?? 29}g', const Color(0xFFA78BFA)),
              _macroPill('Calories', '$consumed', AppColors.primary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _macroPill(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label.toUpperCase(),
          style: AppTypography.caption.copyWith(fontSize: 9, letterSpacing: 0.5),
        ),
      ],
    );
  }

  Widget _planCard(MealSystemPlan plan, int index) {
    final color = _planColors[index % _planColors.length];
    final tag = _planTags[index % _planTags.length];
    final selected = index == _activePlan;

    return GestureDetector(
      onTap: () => setState(() => _activePlan = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 220,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.08) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? color.withValues(alpha: 0.5) : AppColors.cardBorder,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tag.toUpperCase(),
                    style: TextStyle(
                      color: color,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const Spacer(),
                if (selected)
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    child: const Icon(Icons.check, size: 12, color: Colors.white),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(plan.name, style: AppTypography.h3.copyWith(fontSize: 16)),
            Text(plan.tagline, style: AppTypography.caption),
            const SizedBox(height: 10),
            ...plan.features.take(2).map(
                  (f) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(f, style: AppTypography.caption, maxLines: 1),
                        ),
                      ],
                    ),
                  ),
                ),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '₹${plan.pricePerMonth}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(' /mo', style: AppTypography.caption),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
