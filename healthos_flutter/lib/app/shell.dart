import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/session.dart';
import '../data/mock_data.dart';
import 'theme.dart';

class NavItem {
  final String label;
  final IconData icon;
  final String path;
  final Set<UserRole> roles;

  const NavItem(this.label, this.icon, this.path, this.roles);
}

const allNavItems = <NavItem>[
  NavItem('Dashboard', Icons.dashboard_outlined, '/', {...UserRole.values}),
  NavItem('Gyms', Icons.fitness_center_outlined, '/gyms', {UserRole.owner}),
  NavItem('Staff', Icons.badge_outlined, '/staff', {UserRole.owner, UserRole.manager}),
  NavItem('Members', Icons.people_outline, '/members', {...UserRole.values}),
  NavItem('Memberships', Icons.card_membership_outlined, '/plans',
      {UserRole.owner, UserRole.manager}),
  NavItem('Attendance', Icons.event_available_outlined, '/attendance', {...UserRole.values}),
  NavItem('Payments', Icons.payments_outlined, '/payments',
      {UserRole.owner, UserRole.manager, UserRole.receptionist}),
  NavItem('Reports', Icons.insights_outlined, '/reports', {UserRole.owner, UserRole.manager}),
  NavItem('Settings', Icons.settings_outlined, '/settings', {...UserRole.values}),
];

/// Bottom-nav subset for mobile widths.
const mobileNavPaths = ['/', '/members', '/attendance', '/payments', '/settings'];

class AppShell extends ConsumerWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final isWide = MediaQuery.sizeOf(context).width >= 1024;
    final visibleItems =
        allNavItems.where((n) => n.roles.contains(session.role)).toList();
    final location = GoRouterState.of(context).uri.path;

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            _Sidebar(items: visibleItems, location: location),
            Expanded(
              child: Column(
                children: [
                  _TopHeader(session: session),
                  const Divider(height: 1),
                  Expanded(child: child),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final mobileItems =
        visibleItems.where((n) => mobileNavPaths.contains(n.path)).toList();
    var currentIndex = mobileItems.indexWhere((n) =>
        n.path == '/' ? location == '/' : location.startsWith(n.path));
    if (currentIndex < 0) currentIndex = 0;

    return Scaffold(
      appBar: AppBar(
        title: const _BrandTitle(),
        actions: [
          if (session.role == UserRole.owner) const _GymSwitcher(compact: true),
          const _DarkModeButton(),
          const _ProfileMenu(),
        ],
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) => context.go(mobileItems[i].path),
        destinations: [
          for (final n in mobileItems)
            NavigationDestination(icon: Icon(n.icon), label: n.label),
        ],
      ),
    );
  }
}

class _BrandTitle extends StatelessWidget {
  const _BrandTitle();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.fitness_center, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 8),
        const Text('HealthOS', style: TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _Sidebar extends StatelessWidget {
  final List<NavItem> items;
  final String location;
  const _Sidebar({required this.items, required this.location});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 240,
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: _BrandTitle(),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final n in items)
                  _SidebarTile(
                    item: n,
                    selected:
                        n.path == '/' ? location == '/' : location.startsWith(n.path),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  final NavItem item;
  final bool selected;
  const _SidebarTile({required this.item, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        selected: selected,
        selectedTileColor: AppColors.primary.withValues(alpha: 0.1),
        selectedColor: AppColors.primary,
        leading: Icon(item.icon, size: 20),
        title: Text(item.label, style: const TextStyle(fontWeight: FontWeight.w500)),
        onTap: () => context.go(item.path),
      ),
    );
  }
}

class _TopHeader extends ConsumerWidget {
  final Session session;
  const _TopHeader({required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 64,
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          if (session.role == UserRole.owner)
            const _GymSwitcher()
          else
            Text(
              gymById(session.activeGymId).name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          const Spacer(),
          const _DarkModeButton(),
          const SizedBox(width: 8),
          const _ProfileMenu(),
        ],
      ),
    );
  }
}

class _GymSwitcher extends ConsumerWidget {
  final bool compact;
  const _GymSwitcher({this.compact = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: session.activeGymId,
        borderRadius: BorderRadius.circular(10),
        items: [
          for (final g in mockGyms)
            DropdownMenuItem(
              value: g.id,
              child: Text(
                compact ? g.name.split('— ').last : g.name,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
        ],
        onChanged: (id) {
          if (id != null) ref.read(sessionProvider.notifier).switchGym(id);
        },
      ),
    );
  }
}

class _DarkModeButton extends ConsumerWidget {
  const _DarkModeButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = ref.watch(darkModeProvider);
    return IconButton(
      tooltip: dark ? 'Light mode' : 'Dark mode',
      icon: Icon(dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
      onPressed: () => ref.read(darkModeProvider.notifier).toggle(),
    );
  }
}

class _ProfileMenu extends ConsumerWidget {
  const _ProfileMenu();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    return PopupMenuButton<String>(
      tooltip: session.userName,
      offset: const Offset(0, 48),
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(session.userName,
                  style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
              Text(session.role.label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(value: 'profile', child: Text('My profile')),
        const PopupMenuItem(value: 'logout', child: Text('Logout')),
      ],
      onSelected: (v) {
        if (v == 'logout') {
          ref.read(sessionProvider.notifier).logout();
          context.go('/login');
        } else if (v == 'profile') {
          context.go('/settings?tab=3');
        }
      },
      child: CircleAvatar(
        radius: 16,
        backgroundColor: AppColors.primary,
        child: Text(
          session.userName.isEmpty ? '?' : session.userName[0],
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
