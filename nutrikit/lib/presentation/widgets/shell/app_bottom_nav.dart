import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../screens/main/nav_destinations.dart';

/// Bottom navigation chrome: Home · Diet · + · Gym · Plans with a centered docked FAB.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onSelect,
    this.onCenterTap,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback? onCenterTap;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: AppColors.card,
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      surfaceTintColor: Colors.transparent,
      notchMargin: 8,
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      shape: const CircularNotchedRectangle(),
      child: Row(
        children: [
          Expanded(
            child: _NavTab(
              item: kNavDestinations[0],
              selected: currentIndex == 0,
              onTap: () => onSelect(0),
            ),
          ),
          Expanded(
            child: _NavTab(
              item: kNavDestinations[1],
              selected: currentIndex == 1,
              onTap: () => onSelect(1),
            ),
          ),
          const SizedBox(width: 52),
          Expanded(
            child: _NavTab(
              item: kNavDestinations[2],
              selected: currentIndex == 2,
              onTap: () => onSelect(2),
            ),
          ),
          Expanded(
            child: _NavTab(
              item: kNavDestinations[3],
              selected: currentIndex == 3,
              onTap: () => onSelect(3),
            ),
          ),
        ],
      ),
    );
  }

  static Widget centerFab(BuildContext context, {VoidCallback? onTap}) {
    return FloatingActionButton(
      onPressed: onTap ?? () => _showTrackSheet(context),
      backgroundColor: AppColors.primaryDark,
      elevation: 4,
      highlightElevation: 6,
      shape: const CircleBorder(),
      child: const Icon(Icons.add, color: Colors.white, size: 28),
    );
  }

  static void _showTrackSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.cardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Track Now',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            _sheetTile(ctx, Icons.restaurant_outlined, 'Log meal',
                '/home/food?segment=nutriplan'),
            _sheetTile(ctx, Icons.fitness_center_outlined, 'Log workout', '/home/gym'),
            _sheetTile(ctx, Icons.water_drop_outlined, 'Log water', '/home/tracking'),
          ],
        ),
      ),
    );
  }

  static Widget _sheetTile(
      BuildContext ctx, IconData icon, String label, String route) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      onTap: () {
        Navigator.pop(ctx);
        ctx.go(route);
      },
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final NavDestinationItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.muted;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, size: 24, color: color),
            const SizedBox(height: 3),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
