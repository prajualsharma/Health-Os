import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import 'nav_destinations.dart';

/// Adaptive navigation chrome. On wide (web desktop) screens it shows a left
/// [NavigationRail]; on narrow screens it shows a bottom navigation bar.
class ResponsiveShell extends StatelessWidget {
  const ResponsiveShell({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.onSelect,
  });

  final Widget child;
  final int currentIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 900) {
          return Scaffold(
            backgroundColor: AppColors.bg,
            body: Row(
              children: [
                _rail(),
                const VerticalDivider(
                    width: 1, thickness: 1, color: AppColors.cardBorder),
                Expanded(child: child),
              ],
            ),
          );
        }
        return Scaffold(
          backgroundColor: AppColors.bg,
          body: child,
          bottomNavigationBar: _bottomBar(),
        );
      },
    );
  }

  Widget _rail() {
    return SizedBox(
      width: 220,
      child: NavigationRail(
        backgroundColor: AppColors.card,
        selectedIndex: currentIndex,
        onDestinationSelected: onSelect,
        labelType: NavigationRailLabelType.all,
        selectedIconTheme: const IconThemeData(color: AppColors.primary),
        unselectedIconTheme: const IconThemeData(color: AppColors.muted),
        selectedLabelTextStyle: const TextStyle(
            color: AppColors.green, fontWeight: FontWeight.w800),
        unselectedLabelTextStyle: const TextStyle(color: AppColors.muted),
        leading: const Padding(
          padding: EdgeInsets.symmetric(vertical: 24, horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppConstants.appName,
                style: TextStyle(
                  color: AppColors.green,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'FitHub Gym',
                style: TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            ],
          ),
        ),
        destinations: kNavDestinations
            .map(
              (d) => NavigationRailDestination(
                icon: Text(d.emoji, style: const TextStyle(fontSize: 22)),
                label: Text(d.label),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _bottomBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.cardBorder, width: 1.5),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onSelect,
        backgroundColor: AppColors.card,
        selectedItemColor: AppColors.green,
        unselectedItemColor: AppColors.muted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showUnselectedLabels: true,
        items: kNavDestinations
            .map(
              (d) => BottomNavigationBarItem(
                icon: Text(d.emoji, style: const TextStyle(fontSize: 22)),
                label: d.label,
              ),
            )
            .toList(),
      ),
    );
  }
}
