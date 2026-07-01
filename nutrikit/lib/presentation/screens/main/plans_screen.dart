import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/subscription_plan.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/mock_data.dart';
import '../../widgets/common/shimmer_card.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key, this.embedded = false});

  /// When true, omits the scaffold app bar (shell tab).
  final bool embedded;

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  List<SubscriptionPlan> _plans = [];
  bool _loading = true;
  PlanCategory _filter = PlanCategory.diet;

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
        _plans = plans;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _plans = MockData.subscriptionPlans();
        _loading = false;
      });
    }
  }

  List<SubscriptionPlan> get _filtered =>
      _plans.where((p) => p.category == _filter).toList();

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    final bottomPad = widget.embedded && !isWide ? 96.0 : 32.0;

    final content = _loading
        ? const Padding(
            padding: EdgeInsets.all(20),
            child: ShimmerList(count: 4, height: 100),
          )
        : ListView(
            padding: EdgeInsets.fromLTRB(20, widget.embedded ? 16 : 8, 20, bottomPad),
            children: [
              if (widget.embedded)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text('Plans', style: AppTypography.h1.copyWith(fontSize: 22)),
                ),
              Text(
                'Choose what fits your lifestyle',
                style: AppTypography.caption.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 16),
              _CategoryTabs(
                selected: _filter,
                onSelect: (c) => setState(() => _filter = c),
              ),
              const SizedBox(height: 16),
              ..._filtered.map((p) => _PlanCard(
                    plan: p,
                    onTap: () {
                      if (p.category == PlanCategory.couple) {
                        context.push('/plans/couple');
                      } else if (p.route != null) {
                        context.go(p.route!);
                      }
                    },
                  )),
              if (_filter == PlanCategory.couple)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Couple Plan lets you add a partner, order meals for both, '
                    'and track progress together — one subscription, two people.',
                    style: AppTypography.caption,
                  ),
                ),
            ],
          );

    if (widget.embedded) {
      return ColoredBox(
        color: AppColors.bg,
        child: SafeArea(bottom: false, child: content),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.text,
        elevation: 0,
        title: const Text('Plans'),
      ),
      body: SafeArea(child: content),
    );
  }
}

class _CategoryTabs extends StatelessWidget {
  const _CategoryTabs({required this.selected, required this.onSelect});

  final PlanCategory selected;
  final ValueChanged<PlanCategory> onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: PlanCategory.values.map((c) {
          final active = c == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: active,
              showCheckmark: false,
              label: Text('${c.emoji} ${c.label}'),
              onSelected: (_) => onSelect(c),
              selectedColor: AppColors.primarySoft,
              labelStyle: TextStyle(
                fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                color: active ? AppColors.primary : AppColors.muted,
              ),
              side: BorderSide(
                color: active ? AppColors.primary : AppColors.cardBorder,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan, required this.onTap});

  final SubscriptionPlan plan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: plan.highlight
                    ? AppColors.primary.withValues(alpha: 0.4)
                    : AppColors.cardBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(plan.category.emoji, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(plan.name, style: AppTypography.h3),
                          Text(plan.tagline, style: AppTypography.caption),
                        ],
                      ),
                    ),
                    if (plan.pricePerMonth > 0)
                      Text(
                        '₹${plan.pricePerMonth}',
                        style: AppTypography.bodyBold.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                ...plan.features.take(3).map(
                      (f) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle,
                                size: 16, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(f, style: AppTypography.caption),
                            ),
                          ],
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
