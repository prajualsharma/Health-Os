import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/kitchen_store.dart';
import '../../widgets/common.dart';

class CorporateHome extends StatefulWidget {
  const CorporateHome({super.key});

  @override
  State<CorporateHome> createState() => _CorporateHomeState();
}

class _CorporateHomeState extends State<CorporateHome> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KitchenStore>().loadKitchens();
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<KitchenStore>();
    final kitchens = store.kitchens;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud Kitchens'),
        actions: [
          IconButton(
            tooltip: 'Switch to kitchen view',
            icon: const Icon(Icons.swap_horiz),
            onPressed: () async {
              await context.read<AuthProvider>().setRole(SessionRole.kitchen);
              if (context.mounted) context.go('/kitchen');
            },
          ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/corporate/add'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Add kitchen'),
      ),
      body: RefreshIndicator(
        onRefresh: () => store.loadKitchens(),
        child: store.loadingKitchens && kitchens.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                children: [
                  _StatsRow(count: kitchens.length),
                  const SizedBox(height: 20),
                  const Text('Your kitchens',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  if (kitchens.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 60),
                      child: EmptyHint(
                          icon: Icons.storefront,
                          message: 'No kitchens yet.\nAdd your first cloud kitchen.'),
                    )
                  else
                    ...kitchens.map((k) => _KitchenTile(kitchen: k)),
                ],
              ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(label: 'Kitchens', value: '$count', icon: Icons.storefront),
        const SizedBox(width: 12),
        const _StatCard(label: 'Cities', value: '1', icon: Icons.location_city),
        const SizedBox(width: 12),
        const _StatCard(label: 'Status', value: 'Live', icon: Icons.bolt),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(
      {required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(height: 10),
            Text(value,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800)),
            Text(label,
                style: const TextStyle(color: AppColors.muted, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _KitchenTile extends StatelessWidget {
  const _KitchenTile({required this.kitchen});

  final Kitchen kitchen;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.storefront, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(kitchen.name,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  [kitchen.address, kitchen.city]
                      .where((e) => e != null && e.isNotEmpty)
                      .join(', '),
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ],
            ),
          ),
          StatusPill(label: kitchen.status, color: AppColors.success),
        ],
      ),
    );
  }
}
