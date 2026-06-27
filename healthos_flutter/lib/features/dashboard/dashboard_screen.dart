import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../app/widgets.dart';
import '../../core/session.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final isOwner = session.role == UserRole.owner;
    final gym = gymById(session.activeGymId);

    final totalMembers = isOwner
        ? mockGyms.fold<int>(0, (s, g) => s + g.memberCount)
        : gym.memberCount;
    final revenue = isOwner
        ? mockGyms.fold<double>(0, (s, g) => s + g.monthlyRevenue)
        : gym.monthlyRevenue;
    final attendance = isOwner
        ? mockGyms.fold<int>(0, (s, g) => s + g.todayAttendance)
        : gym.todayAttendance;
    final expiring =
        mockMembers.where((m) => m.status == MemberStatus.expiring).length;
    final activeMemberships =
        mockMembers.where((m) => m.status == MemberStatus.active).length * 16;

    final kpis = <Widget>[
      if (isOwner)
        KpiCard(
            title: 'Total Gyms',
            value: '${mockGyms.length}',
            icon: Icons.fitness_center_outlined),
      KpiCard(
          title: 'Total Members',
          value: '$totalMembers',
          icon: Icons.people_outline,
          subtitle: '+28 this month'),
      KpiCard(
          title: 'Active Memberships',
          value: '$activeMemberships',
          icon: Icons.card_membership_outlined,
          color: AppColors.secondary),
      KpiCard(
          title: "Today's Attendance",
          value: '$attendance',
          icon: Icons.event_available_outlined,
          color: AppColors.warning),
      KpiCard(
          title: 'Monthly Revenue',
          value: inr.format(revenue),
          icon: Icons.currency_rupee,
          color: AppColors.secondary,
          subtitle: '+8.4% vs last month'),
      KpiCard(
          title: 'Expiring Memberships',
          value: '$expiring',
          icon: Icons.hourglass_bottom_outlined,
          color: AppColors.danger,
          subtitle: 'Next 7 days'),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Welcome, ${session.userName.split(' ').first}',
            subtitle: isOwner
                ? 'Here is what is happening across your gyms today.'
                : 'Here is what is happening at ${gym.name} today.',
          ),
          LayoutBuilder(builder: (context, constraints) {
            final cols = constraints.maxWidth >= 1100
                ? 3
                : constraints.maxWidth >= 700
                    ? 2
                    : 1;
            return GridView.count(
              crossAxisCount: cols,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: cols == 1 ? 3.4 : 2.6,
              children: kpis,
            );
          }),
          const SizedBox(height: 24),
          _QuickActions(role: session.role),
          const SizedBox(height: 24),
          LayoutBuilder(builder: (context, constraints) {
            final wide = constraints.maxWidth >= 900;
            final revenueCard = SectionCard(
              title: 'Revenue trend (6 months)',
              child: RevenueLineChart(points: mockRevenueSeries),
            );
            final attendanceCard = SectionCard(
              title: 'Attendance this week',
              child: SimpleBarChart(points: mockAttendanceSeries),
            );
            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: revenueCard),
                  const SizedBox(width: 16),
                  Expanded(child: attendanceCard),
                ],
              );
            }
            return Column(children: [
              revenueCard,
              const SizedBox(height: 16),
              attendanceCard,
            ]);
          }),
          const SizedBox(height: 24),
          SectionCard(
            title: 'Expiring memberships',
            trailing: TextButton(
              onPressed: () => context.go('/plans?tab=2'),
              child: const Text('View all'),
            ),
            child: Column(
              children: [
                for (final m in mockMembers
                    .where((m) => m.status == MemberStatus.expiring)
                    .take(5))
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: AppColors.warning.withValues(alpha: 0.15),
                      child: Text(m.name[0],
                          style: const TextStyle(
                              color: AppColors.warning, fontWeight: FontWeight.w700)),
                    ),
                    title: Text(m.name),
                    subtitle: Text('${m.planName} · expires ${dateFmt.format(m.expiresOn)}'),
                    trailing: OutlinedButton(
                      onPressed: () => showComingSoon(context, 'Renewal'),
                      child: const Text('Renew'),
                    ),
                    onTap: () => context.go('/members/${m.id}'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final UserRole role;
  const _QuickActions({required this.role});

  @override
  Widget build(BuildContext context) {
    final actions = <(String, IconData, String)>[
      if (role == UserRole.owner) ('Add Gym', Icons.add_business_outlined, '/gyms/add'),
      ('Add Member', Icons.person_add_outlined, '/members/add'),
      if (role == UserRole.owner || role == UserRole.manager)
        ('Add Staff', Icons.badge_outlined, '/staff/add'),
      if (role == UserRole.owner || role == UserRole.manager)
        ('Create Membership', Icons.card_membership_outlined, '/plans/create'),
      ('Check-In', Icons.qr_code_scanner_outlined, '/attendance?tab=1'),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final (label, icon, path) in actions)
          FilledButton.tonalIcon(
            onPressed: () => context.go(path),
            icon: Icon(icon, size: 18),
            label: Text(label),
          ),
      ],
    );
  }
}
