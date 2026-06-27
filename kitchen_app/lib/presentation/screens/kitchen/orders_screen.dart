import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/models.dart';
import '../../providers/kitchen_store.dart';
import '../../widgets/common.dart';

/// Swiggy/Zomato-style kitchen display: incoming orders grouped into status
/// columns (tabs on mobile) with quick advance/cancel actions.
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  static const _tabs = [
    OrderStatus.newOrder,
    OrderStatus.accepted,
    OrderStatus.preparing,
    OrderStatus.ready,
  ];

  @override
  Widget build(BuildContext context) {
    final store = context.watch<KitchenStore>();
    final kitchen = store.selected;

    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Order board',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              if (kitchen != null)
                Text(kitchen.name,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.muted)),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Refresh',
              icon: const Icon(Icons.refresh),
              onPressed: () => store.refreshBoard(),
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.muted,
            tabs: _tabs.map((s) {
              final count = store.ordersByStatus(s).length;
              return Tab(text: '${s.label} ($count)');
            }).toList(),
          ),
        ),
        body: store.loadingBoard && store.activeOrders.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: _tabs.map((s) => _OrderColumn(status: s)).toList(),
              ),
      ),
    );
  }
}

class _OrderColumn extends StatelessWidget {
  const _OrderColumn({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<KitchenStore>();
    final orders = store.ordersByStatus(status);

    if (orders.isEmpty) {
      return EmptyHint(
        icon: Icons.inbox_outlined,
        message: 'No ${status.label.toLowerCase()} orders',
      );
    }

    return RefreshIndicator(
      onRefresh: () => store.refreshBoard(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (_, i) => _OrderCard(order: orders[i]),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final FoodOrder order;

  @override
  Widget build(BuildContext context) {
    final store = context.read<KitchenStore>();
    final advanceLabel = order.status.advanceLabel;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: order.status.color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(order.orderCode,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 15)),
              const Spacer(),
              StatusPill(label: order.status.label, color: order.status.color),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.person, size: 14, color: AppColors.muted),
              const SizedBox(width: 4),
              Text(order.customerName,
                  style: const TextStyle(color: AppColors.muted, fontSize: 13)),
              const Spacer(),
              Text('${order.itemCount} item(s)',
                  style: const TextStyle(color: AppColors.muted, fontSize: 13)),
            ],
          ),
          const Divider(height: 20, color: AppColors.cardBorder),
          ...order.items.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Text('${line.quantity}×',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(line.name)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('₹${order.total.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 16)),
              const Spacer(),
              if (order.status == OrderStatus.newOrder)
                TextButton(
                  onPressed: () => store.cancelOrder(order),
                  style: TextButton.styleFrom(
                      foregroundColor: AppColors.danger),
                  child: const Text('Reject'),
                ),
              if (advanceLabel != null) ...[
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => store.advanceOrder(order),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: order.status.color,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  child: Text(advanceLabel),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
