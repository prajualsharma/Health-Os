import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/dashboard.dart';
import '../../../data/models/meal.dart';
import '../../../data/services/api_service.dart';
import '../../providers/food_subscription_provider.dart';
import '../../widgets/common/app_avatar.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/calorie_ring.dart';
import '../../widgets/common/error_state.dart';
import '../../widgets/common/macro_bar.dart';
import '../../widgets/common/service_icon_grid.dart';
import '../../widgets/common/shimmer_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DashboardData? _data;
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
      final data = await ApiService.instance.getDashboard();
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
      child: RefreshIndicator(
        color: AppColors.green,
        backgroundColor: AppColors.card,
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isWide ? 1200 : 640),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildBody(isWide),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(bool isWide) {
    if (_error != null) {
      return SizedBox(
        key: const ValueKey('error'),
        height: 400,
        child: ErrorState(message: _error!, onRetry: _load),
      );
    }
    if (_loading || _data == null) {
      return const ShimmerList(
        key: ValueKey('loading'),
        count: 4,
        height: 110,
      );
    }
    final d = _data!;
    return Column(
      key: const ValueKey('content'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(d),
        const SizedBox(height: 20),
        if (isWide)
          _wideLayout(d)
        else
          _narrowLayout(d),
        const SizedBox(height: 22),
        _sectionHeader('Explore'),
        const SizedBox(height: 12),
        const ServiceIconGrid(items: ServiceIconGrid.defaults),
        const SizedBox(height: 18),
        _sectionHeader("Today's Meals"),
        const SizedBox(height: 12),
        ...d.meals.map(_mealTile),
        const SizedBox(height: 8),
        AppButton(
          label: context.watch<FoodSubscriptionProvider>().isSubscribed
              ? "Plan Tomorrow's Meals 🍱"
              : "Order Today's Plan 🛒",
          onPressed: () => context.go(
            context.read<FoodSubscriptionProvider>().isSubscribed
                ? '/home/food?segment=tomorrow'
                : '/home/food?segment=order',
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _header(DashboardData d) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Good morning 👋', style: AppTypography.caption),
              const SizedBox(height: 2),
              Text(d.userName, style: AppTypography.h1),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => context.push('/profile'),
          child: AppAvatar(initials: d.initials, size: 44, accent: true),
        ),
      ],
    );
  }

  Widget _narrowLayout(DashboardData d) {
    return Column(
      children: [
        _calorieCard(d),
        const SizedBox(height: 14),
        Row(
          children: [
            for (final s in d.quickStats) ...[
              _quickStat(s),
              if (s != d.quickStats.last) const SizedBox(width: 12),
            ],
          ],
        ),
      ],
    );
  }

  Widget _wideLayout(DashboardData d) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: _calorieCard(d, inlineStats: true)),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              for (final s in d.quickStats) ...[
                _quickStat(s, fullWidth: true),
                if (s != d.quickStats.last) const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _calorieCard(DashboardData d, {bool inlineStats = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.green.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Today's Progress", style: AppTypography.caption),
                    const SizedBox(height: 4),
                    Text('${d.caloriesConsumed} / ${d.calorieTarget} kcal',
                        style: AppTypography.h3),
                  ],
                ),
              ),
              CalorieRing(
                pct: d.caloriePct,
                size: 84,
                strokeWidth: 9,
                color: AppColors.green,
                label: '${d.caloriePct.round()}%',
                sub: 'done',
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: MacroBar(
                  label: 'Protein',
                  val: d.proteinConsumed.toDouble(),
                  max: d.proteinTarget.toDouble(),
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MacroBar(
                  label: 'Carbs',
                  val: d.carbsConsumed.toDouble(),
                  max: d.carbTarget.toDouble(),
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MacroBar(
                  label: 'Fat',
                  val: d.fatConsumed.toDouble(),
                  max: d.fatTarget.toDouble(),
                  color: AppColors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickStat(QuickStat s, {bool fullWidth = false}) {
    final card = AppCard(
      child: Column(
        children: [
          Text(s.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 6),
          Text(s.value,
              style: const TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              )),
          const SizedBox(height: 2),
          Text(s.label, style: AppTypography.caption),
        ],
      ),
    );
    return fullWidth ? card : Expanded(child: card);
  }

  Widget _sectionHeader(String title) {
    return Text(title, style: AppTypography.h2);
  }

  Widget _mealTile(Meal meal) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Opacity(
        opacity: meal.done ? 0.65 : 1,
        child: GestureDetector(
          onTap: () => context.push('/meal-detail', extra: meal),
          child: AppCard(
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: meal.done
                        ? AppColors.green.withValues(alpha: 0.15)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(meal.emoji,
                        style: const TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(meal.name, style: AppTypography.bodyBold),
                      const SizedBox(height: 2),
                      Text('${meal.slot} · ${meal.calories} kcal',
                          style: AppTypography.caption),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.muted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
