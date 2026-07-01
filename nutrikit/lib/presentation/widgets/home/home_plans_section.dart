import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/subscription_plan.dart';
import '../../../data/services/api_service.dart';
import '../common/shimmer_card.dart';

/// Horizontal preview of subscription plans on the home screen.
class HomePlansSection extends StatefulWidget {
  const HomePlansSection({super.key});

  @override
  State<HomePlansSection> createState() => _HomePlansSectionState();
}

class _HomePlansSectionState extends State<HomePlansSection> {
  List<SubscriptionPlan> _plans = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final plans = await ApiService.instance.getSubscriptionPlans();
      if (!mounted) return;
      setState(() {
        _plans = plans.where((p) => p.highlight).take(4).toList();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Plans', style: AppTypography.h1.copyWith(fontSize: 22)),
            const Spacer(),
            TextButton(
              onPressed: () => context.go('/home/plans'),
              child: const Text(
                'See all',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (_loading)
          const SizedBox(
            height: 120,
            child: ShimmerList(count: 1, height: 120),
          )
        else if (_plans.isEmpty)
          const SizedBox.shrink()
        else
          SizedBox(
            height: 132,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _plans.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, i) => _PlanChip(
                plan: _plans[i],
                onTap: () {
                  final route = _plans[i].route;
                  if (route != null) {
                    context.push(route);
                  } else {
                    context.go('/home/plans');
                  }
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _PlanChip extends StatelessWidget {
  const _PlanChip({required this.plan, required this.onTap});

  final SubscriptionPlan plan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 168,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: plan.highlight
                ? AppColors.primary.withValues(alpha: 0.45)
                : AppColors.cardBorder,
          ),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(plan.category.emoji, style: const TextStyle(fontSize: 22)),
            const Spacer(),
            Text(
              plan.name,
              style: AppTypography.bodyBold.copyWith(fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              plan.tagline,
              style: AppTypography.caption.copyWith(fontSize: 11),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
