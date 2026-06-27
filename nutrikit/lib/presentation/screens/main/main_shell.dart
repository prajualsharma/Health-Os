import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'responsive_shell.dart';

/// Wraps the [StatefulNavigationShell] branches with adaptive navigation.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveShell(
      currentIndex: navigationShell.currentIndex,
      onSelect: _goBranch,
      child: navigationShell,
    );
  }
}
