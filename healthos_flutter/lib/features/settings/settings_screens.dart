import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../app/widgets.dart';
import '../../core/session.dart';
import '../../data/mock_data.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  final int initialTab;
  const SettingsScreen({super.key, this.initialTab = 0});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab =
      TabController(length: 4, vsync: this, initialIndex: widget.initialTab.clamp(0, 3));

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final isOwner = session.role == UserRole.owner;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Column(
            children: [
              const PageHeader(title: 'Settings'),
              TabBar(controller: _tab, isScrollable: true, tabs: const [
                Tab(text: 'Organization'),
                Tab(text: 'Gym'),
                Tab(text: 'Roles & Permissions'),
                Tab(text: 'My Profile'),
              ]),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(controller: _tab, children: [
            _OrgTab(enabled: isOwner),
            const _GymTab(),
            const _RolesTab(),
            const _ProfileTab(),
          ]),
        ),
      ],
    );
  }
}

class _OrgTab extends StatelessWidget {
  final bool enabled;
  const _OrgTab({required this.enabled});

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('Organization settings are available to the Gym Owner only.'),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const TextField(
                    decoration: InputDecoration(labelText: 'Organization name'),
                    controller: null,
                  ),
                  const SizedBox(height: 14),
                  const TextField(
                      decoration: InputDecoration(labelText: 'GSTIN (optional)')),
                  const SizedBox(height: 14),
                  const TextField(
                      decoration: InputDecoration(labelText: 'Support email')),
                  const SizedBox(height: 14),
                  const TextField(
                      decoration: InputDecoration(labelText: 'Support phone')),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => showComingSoon(context, 'Saving org settings'),
                    child: const Text('Save changes'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GymTab extends ConsumerWidget {
  const _GymTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final gym = gymById(session.activeGymId);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(gym.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 20),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Gym phone'),
                    controller: TextEditingController(text: gym.phone),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Address'),
                    controller: TextEditingController(text: gym.address),
                  ),
                  const SizedBox(height: 14),
                  const TextField(
                    decoration: InputDecoration(
                        labelText: 'Opening hours', hintText: '6:00 AM – 10:00 PM'),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => showComingSoon(context, 'Saving gym settings'),
                    child: const Text('Save changes'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RolesTab extends StatelessWidget {
  const _RolesTab();

  static const _permissions = [
    'View dashboard',
    'Manage gyms',
    'Manage staff',
    'Manage members',
    'Manage plans',
    'Check-in members',
    'Collect payments',
    'View reports',
    'Org settings',
  ];

  // owner, manager, trainer, receptionist
  static const _matrix = <List<bool>>[
    [true, true, true, true],
    [true, false, false, false],
    [true, true, false, false],
    [true, true, true, true],
    [true, true, false, false],
    [true, true, true, true],
    [true, true, false, true],
    [true, true, false, false],
    [true, false, false, false],
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Permission')),
                  DataColumn(label: Text('Owner')),
                  DataColumn(label: Text('Manager')),
                  DataColumn(label: Text('Trainer')),
                  DataColumn(label: Text('Receptionist')),
                ],
                rows: [
                  for (var i = 0; i < _permissions.length; i++)
                    DataRow(cells: [
                      DataCell(Text(_permissions[i],
                          style: const TextStyle(fontWeight: FontWeight.w500))),
                      for (final allowed in _matrix[i])
                        DataCell(Icon(
                          allowed ? Icons.check_circle : Icons.remove_circle_outline,
                          size: 18,
                          color: allowed ? AppColors.secondary : Colors.grey,
                        )),
                    ]),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Permission matrix is read-only in this prototype. Editable role management arrives with the backend.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _ProfileTab extends ConsumerWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final dark = ref.watch(darkModeProvider);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          session.userName.isEmpty ? '?' : session.userName[0],
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(session.userName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 16)),
                            Text(session.role.label,
                                style: Theme.of(context).textTheme.bodySmall),
                            Text(session.userContact,
                                style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                      StatusChip(label: session.role.label, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Dark mode'),
                      subtitle: const Text('Toggle the app appearance'),
                      value: dark,
                      onChanged: (_) =>
                          ref.read(darkModeProvider.notifier).toggle(),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.lock_outline),
                      title: const Text('Change password'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => showComingSoon(context, 'Password change'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.logout, color: AppColors.danger),
                      title: const Text('Logout',
                          style: TextStyle(color: AppColors.danger)),
                      onTap: () {
                        ref.read(sessionProvider.notifier).logout();
                        context.go('/login');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
