import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/models.dart';
import '../../providers/kitchen_store.dart';
import '../../widgets/common.dart';
import '../../widgets/kitchen/bistro_card.dart';

const _adminPortalUrl = String.fromEnvironment(
  'ADMIN_PORTAL_URL',
  defaultValue: 'https://admin-portal-eta-beige.vercel.app',
);

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<KitchenStore>();
    final menu = store.menu;
    final live = menu.where((m) => m.available).length;
    final soldOut = menu.length - live;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 100,
            backgroundColor: AppColors.headerDark,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.headerGradient,
                ),
                padding: const EdgeInsets.fromLTRB(16, 56, 16, 12),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Stock & availability',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Toggle items live or sold out during service',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: _StockSummary(live: live, soldOut: soldOut)),
          SliverToBoxAdapter(child: _AdminPortalBanner()),
          if (store.loadingBoard && menu.isEmpty)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (menu.isEmpty)
            const SliverFillRemaining(
              child: EmptyHint(
                icon: Icons.coffee_outlined,
                message: 'No published cafe items yet',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  for (final category in MealCategory.values)
                    ..._categorySection(context, store, category),
                ]),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _categorySection(
      BuildContext context, KitchenStore store, MealCategory category) {
    final items = store.menu.where((m) => m.category == category).toList();
    if (items.isEmpty) return const [];
    return [
      Container(
        margin: const EdgeInsets.only(top: 12, bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.sectionMint,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(category.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Text(
              category.label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryDark,
              ),
            ),
          ],
        ),
      ),
      ...items.map((item) => _AvailabilityTile(item: item)),
    ];
  }
}

class _StockSummary extends StatelessWidget {
  const _StockSummary({required this.live, required this.soldOut});

  final int live;
  final int soldOut;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: _pill('Live on menu', live, AppColors.success),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _pill('Sold out', soldOut, AppColors.dim),
          ),
        ],
      ),
    );
  }

  Widget _pill(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: AppColors.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdminPortalBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.storefront_outlined,
                size: 20, color: AppColors.primaryDark),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Edit menu, photos & sections in NutriKit Admin',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.primary,
                    content: Text('Open $_adminPortalUrl'),
                  ),
                );
              },
              child: const Text('Open'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvailabilityTile extends StatelessWidget {
  const _AvailabilityTile({required this.item});

  final MenuItem item;

  @override
  Widget build(BuildContext context) {
    final store = context.read<KitchenStore>();

    return BistroCard(
      accent: item.available ? AppColors.success : AppColors.dim,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          VegDot(veg: item.veg),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    decoration:
                        item.available ? null : TextDecoration.lineThrough,
                    color: item.available ? AppColors.text : AppColors.dim,
                  ),
                ),
                if (item.description != null && item.description!.isNotEmpty)
                  Text(
                    item.description!,
                    style: const TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                const SizedBox(height: 4),
                Text(
                  '₹${item.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              _LiveChip(available: item.available),
              const SizedBox(height: 8),
              Switch(
                value: item.available,
                onChanged: (_) => store.toggleAvailability(item),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LiveChip extends StatelessWidget {
  const _LiveChip({required this.available});

  final bool available;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: available
            ? AppColors.success.withValues(alpha: 0.12)
            : AppColors.dim.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        available ? 'LIVE' : 'SOLD OUT',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
          color: available ? AppColors.success : AppColors.dim,
        ),
      ),
    );
  }
}
