import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../app/widgets.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';

class GymsListScreen extends StatelessWidget {
  const GymsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Gyms',
            subtitle: 'All locations under your organization',
            actions: [
              FilledButton.icon(
                onPressed: () => context.go('/gyms/add'),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Gym'),
              ),
            ],
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
              childAspectRatio: cols == 1 ? 1.9 : 1.45,
              children: [for (final g in mockGyms) _GymCard(gym: g)],
            );
          }),
        ],
      ),
    );
  }
}

class _GymCard extends StatelessWidget {
  final Gym gym;
  const _GymCard({required this.gym});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.go('/gyms/${gym.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.fitness_center, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(gym.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text(gym.city, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ]),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Stat(label: 'Members', value: '${gym.memberCount}'),
                  _Stat(label: 'Staff', value: '${gym.staffCount}'),
                  _Stat(label: 'Revenue/mo', value: inr.format(gym.monthlyRevenue)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class AddGymScreen extends StatelessWidget {
  const AddGymScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(title: 'Add Gym', subtitle: 'Create a new gym location'),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const TextField(
                        decoration: InputDecoration(labelText: 'Gym name')),
                    const SizedBox(height: 14),
                    const TextField(decoration: InputDecoration(labelText: 'City')),
                    const SizedBox(height: 14),
                    const TextField(
                        maxLines: 2,
                        decoration: InputDecoration(labelText: 'Address')),
                    const SizedBox(height: 14),
                    const TextField(
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(labelText: 'Contact phone')),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Assign manager'),
                      items: [
                        for (final s in mockStaff.where((s) => s.role == StaffRole.manager))
                          DropdownMenuItem(value: s.id, child: Text(s.name)),
                      ],
                      onChanged: (_) {},
                    ),
                    const SizedBox(height: 24),
                    Row(children: [
                      FilledButton(
                        onPressed: () {
                          showComingSoon(context, 'Saving a gym');
                          context.go('/gyms');
                        },
                        child: const Text('Create Gym'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () => context.go('/gyms'),
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

class GymDetailsScreen extends StatelessWidget {
  final String gymId;
  const GymDetailsScreen({super.key, required this.gymId});

  @override
  Widget build(BuildContext context) {
    final gym = gymById(gymId);
    final staff = mockStaff.where((s) => s.gymId == gymId).toList();
    final members = mockMembers.where((m) => m.gymId == gymId).toList();

    return DefaultTabController(
      length: 2,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: gym.name,
              subtitle: '${gym.address}, ${gym.city} · ${gym.phone}',
              actions: [
                OutlinedButton.icon(
                  onPressed: () => showComingSoon(context, 'Edit gym'),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit'),
                ),
              ],
            ),
            LayoutBuilder(builder: (context, constraints) {
              final cols = constraints.maxWidth >= 900 ? 4 : 2;
              return GridView.count(
                crossAxisCount: cols,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 2.4,
                children: [
                  KpiCard(
                      title: 'Members',
                      value: '${gym.memberCount}',
                      icon: Icons.people_outline),
                  KpiCard(
                      title: 'Staff',
                      value: '${gym.staffCount}',
                      icon: Icons.badge_outlined,
                      color: AppColors.secondary),
                  KpiCard(
                      title: "Today's Attendance",
                      value: '${gym.todayAttendance}',
                      icon: Icons.event_available_outlined,
                      color: AppColors.warning),
                  KpiCard(
                      title: 'Revenue/mo',
                      value: inr.format(gym.monthlyRevenue),
                      icon: Icons.currency_rupee,
                      color: AppColors.secondary),
                ],
              );
            }),
            const SizedBox(height: 24),
            SectionCard(
              title: 'Gym statistics',
              child: RevenueLineChart(points: mockRevenueSeries),
            ),
            const SizedBox(height: 24),
            const TabBar(tabs: [Tab(text: 'Staff'), Tab(text: 'Members')]),
            SizedBox(
              height: 420,
              child: TabBarView(children: [
                ListView(
                  children: [
                    for (final s in staff)
                      ListTile(
                        leading: CircleAvatar(child: Text(s.name[0])),
                        title: Text(s.name),
                        subtitle: Text(s.role.label),
                        trailing: Text(s.phone),
                        onTap: () => context.go('/staff/${s.id}'),
                      ),
                  ],
                ),
                ListView(
                  children: [
                    for (final m in members.take(15))
                      ListTile(
                        leading: CircleAvatar(child: Text(m.name[0])),
                        title: Text(m.name),
                        subtitle: Text(m.planName),
                        trailing: memberStatusChip(m.status),
                        onTap: () => context.go('/members/${m.id}'),
                      ),
                  ],
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
