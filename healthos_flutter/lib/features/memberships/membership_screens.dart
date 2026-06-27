import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../app/widgets.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';

class MembershipsScreen extends StatefulWidget {
  final int initialTab;
  const MembershipsScreen({super.key, this.initialTab = 0});

  @override
  State<MembershipsScreen> createState() => _MembershipsScreenState();
}

class _MembershipsScreenState extends State<MembershipsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab =
      TabController(length: 3, vsync: this, initialIndex: widget.initialTab.clamp(0, 2));

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Column(
            children: [
              PageHeader(
                title: 'Memberships',
                subtitle: 'Plans, renewals and expiries',
                actions: [
                  FilledButton.icon(
                    onPressed: () => context.go('/plans/create'),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Create Plan'),
                  ),
                ],
              ),
              TabBar(controller: _tab, tabs: const [
                Tab(text: 'Plans'),
                Tab(text: 'Renewals'),
                Tab(text: 'Expiring'),
              ]),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(controller: _tab, children: const [
            _PlansTab(),
            _RenewalsTab(),
            _ExpiringTab(),
          ]),
        ),
      ],
    );
  }
}

class _PlansTab extends StatelessWidget {
  const _PlansTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(builder: (context, constraints) {
        final cols = constraints.maxWidth >= 1100
            ? 4
            : constraints.maxWidth >= 700
                ? 2
                : 1;
        return GridView.count(
          crossAxisCount: cols,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: cols == 1 ? 1.5 : 0.95,
          children: [for (final p in mockPlans) _PlanCard(plan: p)],
        );
      }),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final MembershipPlan plan;
  const _PlanCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(plan.name,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 4),
            Text('${plan.durationMonths} month${plan.durationMonths > 1 ? 's' : ''}',
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            Text(inr.format(plan.price),
                style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 24,
                    color: AppColors.primary)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (final f in plan.features)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(children: [
                        const Icon(Icons.check_circle,
                            size: 15, color: AppColors.secondary),
                        const SizedBox(width: 6),
                        Expanded(
                            child: Text(f,
                                style: const TextStyle(fontSize: 12.5),
                                overflow: TextOverflow.ellipsis)),
                      ]),
                    ),
                ],
              ),
            ),
            Text('${plan.activeMembers} active members',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.secondary)),
          ],
        ),
      ),
    );
  }
}

class _RenewalsTab extends StatelessWidget {
  const _RenewalsTab();

  @override
  Widget build(BuildContext context) {
    final renewable = mockMembers
        .where((m) =>
            m.status == MemberStatus.expiring || m.status == MemberStatus.expired)
        .toList();
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Card(
          child: Column(children: [
            for (final m in renewable)
              ListTile(
                leading: CircleAvatar(child: Text(m.name[0])),
                title: Text(m.name),
                subtitle:
                    Text('${m.planName} · expires ${dateFmt.format(m.expiresOn)}'),
                trailing: FilledButton.tonal(
                  onPressed: () => _showRenewDialog(context, m),
                  child: const Text('Renew'),
                ),
              ),
          ]),
        ),
      ],
    );
  }

  void _showRenewDialog(BuildContext context, Member member) {
    var planId = mockPlans.first.id;
    showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Renew — ${member.name}'),
          content: DropdownButtonFormField<String>(
            initialValue: planId,
            decoration: const InputDecoration(labelText: 'Plan'),
            items: [
              for (final p in mockPlans)
                DropdownMenuItem(
                    value: p.id, child: Text('${p.name} — ${inr.format(p.price)}')),
            ],
            onChanged: (v) => setState(() => planId = v ?? planId),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                showComingSoon(context, 'Renewal');
              },
              child: const Text('Renew & Collect'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpiringTab extends StatelessWidget {
  const _ExpiringTab();

  @override
  Widget build(BuildContext context) {
    final expiring =
        mockMembers.where((m) => m.status == MemberStatus.expiring).toList();
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Card(
          child: Column(children: [
            for (final m in expiring)
              ListTile(
                leading: const Icon(Icons.hourglass_bottom, color: AppColors.warning),
                title: Text(m.name),
                subtitle: Text(
                    '${m.planName} · ${gymById(m.gymId).name} · expires ${dateFmt.format(m.expiresOn)}'),
                trailing: OutlinedButton(
                  onPressed: () => showComingSoon(context, 'Reminder'),
                  child: const Text('Send reminder'),
                ),
              ),
          ]),
        ),
      ],
    );
  }
}

class CreatePlanScreen extends StatelessWidget {
  const CreatePlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(
              title: 'Create Plan', subtitle: 'Define a new membership plan'),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const TextField(decoration: InputDecoration(labelText: 'Plan name')),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(labelText: 'Duration'),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('1 month')),
                        DropdownMenuItem(value: 3, child: Text('3 months')),
                        DropdownMenuItem(value: 6, child: Text('6 months')),
                        DropdownMenuItem(value: 12, child: Text('12 months')),
                      ],
                      onChanged: (_) {},
                    ),
                    const SizedBox(height: 14),
                    const TextField(
                      keyboardType: TextInputType.number,
                      decoration:
                          InputDecoration(labelText: 'Price (₹)', prefixText: '₹ '),
                    ),
                    const SizedBox(height: 14),
                    const TextField(
                      maxLines: 3,
                      decoration: InputDecoration(
                          labelText: 'Features (one per line)',
                          alignLabelWithHint: true),
                    ),
                    const SizedBox(height: 24),
                    Row(children: [
                      FilledButton(
                        onPressed: () {
                          showComingSoon(context, 'Saving a plan');
                          context.go('/plans');
                        },
                        child: const Text('Create Plan'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () => context.go('/plans'),
                        child: const Text('Cancel'),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
