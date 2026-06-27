import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../app/widgets.dart';
import '../../core/session.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';

class PaymentsScreen extends ConsumerStatefulWidget {
  final int initialTab;
  const PaymentsScreen({super.key, this.initialTab = 0});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab =
      TabController(length: 4, vsync: this, initialIndex: widget.initialTab.clamp(0, 3));

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Column(
            children: [
              PageHeader(
                title: 'Payments',
                subtitle: 'Collections, history and revenue',
                actions: [
                  FilledButton.icon(
                    onPressed: () => _showCollectDialog(context),
                    icon: const Icon(Icons.add_card, size: 18),
                    label: const Text('Collect Payment'),
                  ),
                ],
              ),
              TabBar(controller: _tab, isScrollable: true, tabs: const [
                Tab(text: 'Revenue'),
                Tab(text: 'History'),
                Tab(text: 'Pending'),
                Tab(text: 'Invoices'),
              ]),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(controller: _tab, children: const [
            _RevenueTab(),
            _HistoryTab(),
            _PendingTab(),
            _InvoicesTab(),
          ]),
        ),
      ],
    );
  }

  void _showCollectDialog(BuildContext context) {
    String? memberId = mockMembers.first.id;
    var planId = mockPlans.first.id;
    var method = 'UPI';
    showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Collect payment'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: memberId,
                  decoration: const InputDecoration(labelText: 'Member'),
                  items: [
                    for (final m in mockMembers.take(20))
                      DropdownMenuItem(value: m.id, child: Text('${m.name} (${m.id})')),
                  ],
                  onChanged: (v) => setState(() => memberId = v),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: planId,
                  decoration: const InputDecoration(labelText: 'Plan'),
                  items: [
                    for (final p in mockPlans)
                      DropdownMenuItem(
                          value: p.id,
                          child: Text('${p.name} — ${inr.format(p.price)}')),
                  ],
                  onChanged: (v) => setState(() => planId = v ?? planId),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: method,
                  decoration: const InputDecoration(labelText: 'Payment method'),
                  items: const [
                    DropdownMenuItem(value: 'UPI', child: Text('UPI')),
                    DropdownMenuItem(value: 'Card', child: Text('Card')),
                    DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                    DropdownMenuItem(value: 'Netbanking', child: Text('Netbanking')),
                  ],
                  onChanged: (v) => setState(() => method = v ?? method),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                showComingSoon(context, 'Payment collection');
              },
              child: const Text('Collect & Generate Invoice'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RevenueTab extends StatelessWidget {
  const _RevenueTab();

  @override
  Widget build(BuildContext context) {
    final paid = mockPayments.where((p) => p.status == PaymentStatus.paid);
    final pending = mockPayments.where((p) => p.status != PaymentStatus.paid);
    final collected = paid.fold<double>(0, (s, p) => s + p.amount);
    final outstanding = pending.fold<double>(0, (s, p) => s + p.amount);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        LayoutBuilder(builder: (context, constraints) {
          final cols = constraints.maxWidth >= 900 ? 3 : 1;
          return GridView.count(
            crossAxisCount: cols,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: cols == 1 ? 3.4 : 2.6,
            children: [
              KpiCard(
                  title: 'Collected (6 mo)',
                  value: inr.format(collected),
                  icon: Icons.savings_outlined,
                  color: AppColors.secondary),
              KpiCard(
                  title: 'Outstanding',
                  value: inr.format(outstanding),
                  icon: Icons.hourglass_bottom,
                  color: AppColors.danger),
              KpiCard(
                  title: 'Avg ticket size',
                  value: inr.format(collected / (paid.isEmpty ? 1 : paid.length)),
                  icon: Icons.receipt_long_outlined),
            ],
          );
        }),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Monthly revenue',
          child: RevenueLineChart(points: mockRevenueSeries),
        ),
      ],
    );
  }
}

class _HistoryTab extends ConsumerWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final isOwner = session.role == UserRole.owner;
    final payments = isOwner
        ? mockPayments
        : mockPayments.where((p) => p.gymId == session.activeGymId).toList();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Card(
          child: Column(children: [
            for (final p in payments)
              ListTile(
                leading: const Icon(Icons.receipt_long_outlined),
                title: Text('${p.memberName} · ${p.planName}'),
                subtitle: Text('${p.id} · ${dateFmt.format(p.date)} · ${p.method}'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(inr.format(p.amount),
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    paymentStatusChip(p.status),
                  ],
                ),
                onTap: () => _showInvoice(context, p),
              ),
          ]),
        ),
      ],
    );
  }
}

class _PendingTab extends StatelessWidget {
  const _PendingTab();

  @override
  Widget build(BuildContext context) {
    final pending =
        mockPayments.where((p) => p.status != PaymentStatus.paid).toList();
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Card(
          child: Column(children: [
            for (final p in pending)
              ListTile(
                leading: Icon(
                  p.status == PaymentStatus.overdue
                      ? Icons.error_outline
                      : Icons.schedule,
                  color: p.status == PaymentStatus.overdue
                      ? AppColors.danger
                      : AppColors.warning,
                ),
                title: Text(p.memberName),
                subtitle: Text('${p.planName} · due since ${dateFmt.format(p.date)}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(inr.format(p.amount),
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(width: 12),
                    FilledButton.tonal(
                      onPressed: () => showComingSoon(context, 'Collection'),
                      child: const Text('Collect'),
                    ),
                  ],
                ),
              ),
          ]),
        ),
      ],
    );
  }
}

class _InvoicesTab extends StatelessWidget {
  const _InvoicesTab();

  @override
  Widget build(BuildContext context) {
    final paid = mockPayments.where((p) => p.status == PaymentStatus.paid).toList();
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Card(
          child: Column(children: [
            for (final p in paid.take(20))
              ListTile(
                leading: const Icon(Icons.description_outlined,
                    color: AppColors.primary),
                title: Text(p.id),
                subtitle: Text('${p.memberName} · ${dateFmt.format(p.date)}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(inr.format(p.amount),
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    IconButton(
                      tooltip: 'View invoice',
                      icon: const Icon(Icons.open_in_new, size: 18),
                      onPressed: () => _showInvoice(context, p),
                    ),
                  ],
                ),
              ),
          ]),
        ),
      ],
    );
  }
}

void _showInvoice(BuildContext context, Payment p) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Invoice ${p.id}'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _invoiceRow('Member', p.memberName),
            _invoiceRow('Gym', gymById(p.gymId).name),
            _invoiceRow('Plan', p.planName),
            _invoiceRow('Date', dateFmt.format(p.date)),
            _invoiceRow('Method', p.method),
            const Divider(height: 24),
            _invoiceRow('Amount', inr.format(p.amount), bold: true),
            const SizedBox(height: 8),
            paymentStatusChip(p.status),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        FilledButton.icon(
          onPressed: () {
            Navigator.pop(context);
            showComingSoon(context, 'Invoice PDF download');
          },
          icon: const Icon(Icons.download_outlined, size: 18),
          label: const Text('Download PDF'),
        ),
      ],
    ),
  );
}

Widget _invoiceRow(String label, String value, {bool bold = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        SizedBox(width: 90, child: Text(label, style: const TextStyle(fontSize: 13))),
        Expanded(
          child: Text(value,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
                  fontSize: bold ? 16 : 14)),
        ),
      ],
    ),
  );
}
