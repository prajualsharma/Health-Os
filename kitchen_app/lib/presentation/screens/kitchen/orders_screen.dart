import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/models.dart';
import '../../providers/kitchen_store.dart';
import '../../widgets/common.dart';
import '../../widgets/kitchen/bistro_card.dart';
import '../../widgets/kitchen/ops_summary_bar.dart';

/// Blinkit Bistro / Zepto Cafe ops board — summary chips + ticket cards.
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
    final counts = {
      for (final s in _tabs) s: store.ordersByStatus(s).length,
    };
    final wide = MediaQuery.sizeOf(context).width >= 900;

    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverAppBar(
              pinned: true,
              expandedHeight: 120,
              backgroundColor: AppColors.headerDark,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.headerGradient,
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 56, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        'Live orders',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (kitchen != null)
                        Text(
                          kitchen.name,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                IconButton(
                  tooltip: 'Refresh',
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: () => store.refreshBoard(),
                ),
              ],
              bottom: wide
                  ? null
                  : PreferredSize(
                      preferredSize: const Size.fromHeight(48),
                      child: Container(
                        color: AppColors.surface,
                        child: TabBar(
                          isScrollable: true,
                          tabs: _tabs
                              .map((s) => Tab(text: '${s.label} (${counts[s]})'))
                              .toList(),
                        ),
                      ),
                    ),
            ),
            SliverToBoxAdapter(
              child: OpsSummaryBar(counts: counts),
            ),
          ],
          body: store.loadingBoard && store.activeOrders.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth >= 900) {
                      return const _KanbanBoard(statuses: _tabs);
                    }
                    return TabBarView(
                      children: _tabs
                          .map((s) => _OrderColumn(status: s))
                          .toList(),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _KanbanBoard extends StatelessWidget {
  const _KanbanBoard({required this.statuses});

  final List<OrderStatus> statuses;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: statuses
          .map(
            (s) => Expanded(
              child: _OrderColumn(status: s, dense: true),
            ),
          )
          .toList(),
    );
  }
}

class _OrderColumn extends StatelessWidget {
  const _OrderColumn({required this.status, this.dense = false});

  final OrderStatus status;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<KitchenStore>();
    final orders = store.ordersByStatus(status);

    if (orders.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(dense ? 8 : 16),
        child: EmptyHint(
          icon: Icons.inbox_outlined,
          message: 'No ${status.label.toLowerCase()} orders',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => store.refreshBoard(),
      child: ListView.builder(
        padding: EdgeInsets.all(dense ? 8 : 16),
        itemCount: orders.length,
        itemBuilder: (_, i) => _OrderTicket(order: orders[i]),
      ),
    );
  }
}

class _OrderTicket extends StatelessWidget {
  const _OrderTicket({required this.order});

  final FoodOrder order;

  String _timeAgo(DateTime at) {
    final mins = DateTime.now().difference(at).inMinutes;
    if (mins < 1) return 'Just now';
    if (mins < 60) return '$mins min ago';
    return '${mins ~/ 60}h ago';
  }

  @override
  Widget build(BuildContext context) {
    final store = context.read<KitchenStore>();
    final advanceLabel = order.status.advanceLabel;

    return BistroCard(
      accent: order.status.color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                order.orderCode,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              StatusPill(label: order.status.label, color: order.status.color),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _timeAgo(order.createdAt),
            style: const TextStyle(color: AppColors.dim, fontSize: 11),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 14, color: AppColors.muted),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  order.customerName,
                  style: const TextStyle(color: AppColors.muted, fontSize: 13),
                ),
              ),
              Text(
                '${order.itemCount} items',
                style: const TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            ],
          ),
          const Divider(height: 20),
          ...order.items.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${line.quantity}×',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(line.name)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                '₹${order.total.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                  color: AppColors.text,
                ),
              ),
              const Spacer(),
              if (order.status == OrderStatus.newOrder)
                TextButton(
                  onPressed: () => store.cancelOrder(order),
                  style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                  child: const Text('Reject'),
                ),
              if (advanceLabel != null) ...[
                const SizedBox(width: 4),
                ElevatedButton(
                  onPressed: () => store.advanceOrder(order),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
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
