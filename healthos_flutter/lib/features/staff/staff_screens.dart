import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../app/widgets.dart';
import '../../core/session.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';

class StaffListScreen extends ConsumerStatefulWidget {
  const StaffListScreen({super.key});

  @override
  ConsumerState<StaffListScreen> createState() => _StaffListScreenState();
}

class _StaffListScreenState extends ConsumerState<StaffListScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final isOwner = session.role == UserRole.owner;
    var staff = isOwner
        ? mockStaff
        : mockStaff.where((s) => s.gymId == session.activeGymId).toList();
    if (_query.isNotEmpty) {
      staff = staff
          .where((s) => s.name.toLowerCase().contains(_query.toLowerCase()))
          .toList();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Staff',
            subtitle: isOwner
                ? 'Across all gyms'
                : 'At ${gymById(session.activeGymId).name}',
            actions: [
              FilledButton.icon(
                onPressed: () => context.go('/staff/add'),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Staff'),
              ),
            ],
          ),
          SizedBox(
            width: 360,
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search staff…',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                for (final s in staff)
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                      child: Text(s.name[0],
                          style: const TextStyle(
                              color: AppColors.primary, fontWeight: FontWeight.w700)),
                    ),
                    title: Text(s.name,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('${s.role.label} · ${gymById(s.gymId).name}'),
                    trailing: StatusChip(
                      label: s.role.label,
                      color: switch (s.role) {
                        StaffRole.manager => AppColors.primary,
                        StaffRole.trainer => AppColors.secondary,
                        StaffRole.receptionist => AppColors.warning,
                      },
                    ),
                    onTap: () => context.go('/staff/${s.id}'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AddStaffScreen extends StatefulWidget {
  const AddStaffScreen({super.key});

  @override
  State<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends State<AddStaffScreen> {
  StaffRole _role = StaffRole.trainer;
  String _gymId = mockGyms.first.id;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(
              title: 'Add Staff',
              subtitle: 'Invite a staff member and assign their role and gym'),
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
                        decoration: InputDecoration(labelText: 'Email')),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<StaffRole>(
                      initialValue: _role,
                      decoration: const InputDecoration(labelText: 'Role'),
                      items: [
                        for (final r in StaffRole.values)
                          DropdownMenuItem(value: r, child: Text(r.label)),
                      ],
                      onChanged: (r) => setState(() => _role = r ?? _role),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: _gymId,
                      decoration: const InputDecoration(labelText: 'Assign gym'),
                      items: [
                        for (final g in mockGyms)
                          DropdownMenuItem(value: g.id, child: Text(g.name)),
                      ],
                      onChanged: (g) => setState(() => _gymId = g ?? _gymId),
                    ),
                    const SizedBox(height: 24),
                    Row(children: [
                      FilledButton(
                        onPressed: () {
                          showComingSoon(context, 'Saving staff');
                          context.go('/staff');
                        },
                        child: const Text('Add Staff'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () => context.go('/staff'),
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

class StaffDetailsScreen extends StatelessWidget {
  final String staffId;
  const StaffDetailsScreen({super.key, required this.staffId});

  @override
  Widget build(BuildContext context) {
    final staff = mockStaff.firstWhere((s) => s.id == staffId,
        orElse: () => mockStaff.first);
    final gym = gymById(staff.gymId);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: staff.name,
            subtitle: '${staff.role.label} · ${gym.name}',
            actions: [
              OutlinedButton.icon(
                onPressed: () => _showReassignDialog(context, staff),
                icon: const Icon(Icons.swap_horiz, size: 18),
                label: const Text('Reassign role / gym'),
              ),
            ],
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _InfoRow(label: 'Employee ID', value: staff.id),
                    _InfoRow(label: 'Phone', value: staff.phone),
                    _InfoRow(label: 'Email', value: staff.email),
                    _InfoRow(label: 'Role', value: staff.role.label),
                    _InfoRow(label: 'Gym', value: gym.name),
                    _InfoRow(label: 'Joined', value: dateFmt.format(staff.joinedOn)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showReassignDialog(BuildContext context, StaffMember staff) {
    var role = staff.role;
    var gymId = staff.gymId;
    showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Reassign role / gym'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<StaffRole>(
                initialValue: role,
                decoration: const InputDecoration(labelText: 'Role'),
                items: [
                  for (final r in StaffRole.values)
                    DropdownMenuItem(value: r, child: Text(r.label)),
                ],
                onChanged: (r) => setState(() => role = r ?? role),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: gymId,
                decoration: const InputDecoration(labelText: 'Gym'),
                items: [
                  for (final g in mockGyms)
                    DropdownMenuItem(value: g.id, child: Text(g.name)),
                ],
                onChanged: (g) => setState(() => gymId = g ?? gymId),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                showComingSoon(context, 'Reassignment');
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
