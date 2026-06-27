import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../app/widgets.dart';
import '../../core/session.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';

const _pageSize = 10;

class MembersListScreen extends ConsumerStatefulWidget {
  const MembersListScreen({super.key});

  @override
  ConsumerState<MembersListScreen> createState() => _MembersListScreenState();
}

class _MembersListScreenState extends ConsumerState<MembersListScreen> {
  String _query = '';
  MemberStatus? _statusFilter;
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final isOwner = session.role == UserRole.owner;

    var members = isOwner
        ? mockMembers
        : mockMembers.where((m) => m.gymId == session.activeGymId).toList();
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      members = members
          .where((m) =>
              m.name.toLowerCase().contains(q) ||
              m.phone.contains(q) ||
              m.id.toLowerCase().contains(q))
          .toList();
    }
    if (_statusFilter != null) {
      members = members.where((m) => m.status == _statusFilter).toList();
    }

    final pageCount = (members.length / _pageSize).ceil().clamp(1, 999);
    final page = _page.clamp(0, pageCount - 1);
    final visible = members.skip(page * _pageSize).take(_pageSize).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Members',
            subtitle: '${members.length} members',
            actions: [
              FilledButton.icon(
                onPressed: () => context.go('/members/add'),
                icon: const Icon(Icons.person_add_outlined, size: 18),
                label: const Text('Add Member'),
              ),
            ],
          ),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 320,
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search name, phone, ID…',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (v) => setState(() {
                    _query = v;
                    _page = 0;
                  }),
                ),
              ),
              for (final s in [null, ...MemberStatus.values])
                ChoiceChip(
                  label: Text(s == null ? 'All' : s.name[0].toUpperCase() + s.name.substring(1)),
                  selected: _statusFilter == s,
                  onSelected: (_) => setState(() {
                    _statusFilter = s;
                    _page = 0;
                  }),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                for (final m in visible)
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                      child: Text(m.name[0],
                          style: const TextStyle(
                              color: AppColors.primary, fontWeight: FontWeight.w700)),
                    ),
                    title: Text(m.name,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle:
                        Text('${m.id} · ${m.planName} · expires ${dateFmt.format(m.expiresOn)}'),
                    trailing: memberStatusChip(m.status),
                    onTap: () => context.go('/members/${m.id}'),
                  ),
                if (visible.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('No members match your filters.'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Page ${page + 1} of $pageCount',
                  style: Theme.of(context).textTheme.bodySmall),
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: page > 0 ? () => setState(() => _page = page - 1) : null,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed:
                    page < pageCount - 1 ? () => setState(() => _page = page + 1) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AddMemberScreen extends StatefulWidget {
  const AddMemberScreen({super.key});

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  String _planId = mockPlans.first.id;
  String _gymId = mockGyms.first.id;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(
              title: 'Add Member', subtitle: 'Register a new gym member'),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const TextField(decoration: InputDecoration(labelText: 'Full name')),
                    const SizedBox(height: 14),
                    const TextField(
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(labelText: 'Mobile number')),
                    const SizedBox(height: 14),
                    const TextField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(labelText: 'Email (optional)')),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: _gymId,
                      decoration: const InputDecoration(labelText: 'Gym'),
                      items: [
                        for (final g in mockGyms)
                          DropdownMenuItem(value: g.id, child: Text(g.name)),
                      ],
                      onChanged: (g) => setState(() => _gymId = g ?? _gymId),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: _planId,
                      decoration: const InputDecoration(labelText: 'Membership plan'),
                      items: [
                        for (final p in mockPlans)
                          DropdownMenuItem(
                              value: p.id,
                              child: Text('${p.name} — ${inr.format(p.price)}')),
                      ],
                      onChanged: (p) => setState(() => _planId = p ?? _planId),
                    ),
                    const SizedBox(height: 24),
                    Row(children: [
                      FilledButton(
                        onPressed: () {
                          showComingSoon(context, 'Saving a member');
                          context.go('/members');
                        },
                        child: const Text('Add Member'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () => context.go('/members'),
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

class MemberProfileScreen extends StatelessWidget {
  final String memberId;
  const MemberProfileScreen({super.key, required this.memberId});

  @override
  Widget build(BuildContext context) {
    final member = mockMembers.firstWhere((m) => m.id == memberId,
        orElse: () => mockMembers.first);
    final gym = gymById(member.gymId);
    final payments =
        mockPayments.where((p) => p.memberName == member.name).toList();
    final attendance =
        mockAttendanceToday.where((a) => a.memberName == member.name).toList();

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              children: [
                PageHeader(
                  title: member.name,
                  subtitle:
                      '${member.id} · ${gym.name} · ${member.phone}',
                  actions: [
                    if (member.pendingAmount > 0)
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: StatusChip(
                            label: 'Due ${inr.format(member.pendingAmount)}',
                            color: AppColors.danger),
                      ),
                    memberStatusChip(member.status),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: () => showComingSoon(context, 'Renewal'),
                      icon: const Icon(Icons.autorenew, size: 18),
                      label: const Text('Renew'),
                    ),
                  ],
                ),
                const TabBar(tabs: [
                  Tab(text: 'Membership History'),
                  Tab(text: 'Attendance'),
                  Tab(text: 'Payments'),
                ]),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(children: [
              ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Card(
                    child: Column(children: [
                      ListTile(
                        leading: const Icon(Icons.card_membership,
                            color: AppColors.primary),
                        title: Text(member.planName),
                        subtitle: Text(
                            '${dateFmt.format(member.joinedOn)} → ${dateFmt.format(member.expiresOn)}'),
                        trailing: memberStatusChip(member.status),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.history, color: Colors.grey),
                        title: const Text('Monthly Basic'),
                        subtitle: Text(
                            '${dateFmt.format(member.joinedOn.subtract(const Duration(days: 90)))} → ${dateFmt.format(member.joinedOn)}'),
                        trailing:
                            const StatusChip(label: 'Completed', color: Colors.blueGrey),
                      ),
                    ]),
                  ),
                ],
              ),
              ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Card(
                    child: Column(children: [
                      if (attendance.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(32),
                          child: Text('No attendance records today.'),
                        ),
                      for (final a in attendance)
                        ListTile(
                          leading: const Icon(Icons.login, color: AppColors.secondary),
                          title: Text('Check-in ${timeFmt.format(a.checkIn)}'),
                          subtitle: Text(a.checkOut == null
                              ? 'Currently in gym'
                              : 'Check-out ${timeFmt.format(a.checkOut!)}'),
                        ),
                    ]),
                  ),
                ],
              ),
              ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Card(
                    child: Column(children: [
                      if (payments.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(32),
                          child: Text('No payment records.'),
                        ),
                      for (final p in payments)
                        ListTile(
                          leading: const Icon(Icons.receipt_long_outlined),
                          title: Text('${p.id} · ${p.planName}'),
                          subtitle: Text('${dateFmt.format(p.date)} · ${p.method}'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(inr.format(p.amount),
                                  style:
                                      const TextStyle(fontWeight: FontWeight.w700)),
                              paymentStatusChip(p.status),
                            ],
                          ),
                        ),
                    ]),
                  ),
                ],
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
