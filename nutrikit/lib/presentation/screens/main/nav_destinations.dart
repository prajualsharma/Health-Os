import 'package:flutter/material.dart';

class NavDestinationItem {
  const NavDestinationItem({
    required this.icon,
    required this.label,
    required this.branchIndex,
  });

  final IconData icon;
  final String label;
  /// Indexed stack branch (0=home, 1=diet, 2=gym, 3=plans). -1 for non-branch slots.
  final int branchIndex;
}

/// Side nav + bottom bar destinations (Home, Diet, Gym, Plans).
const List<NavDestinationItem> kNavDestinations = [
  NavDestinationItem(
    icon: Icons.home_outlined,
    label: 'Home',
    branchIndex: 0,
  ),
  NavDestinationItem(
    icon: Icons.restaurant_outlined,
    label: 'Diet',
    branchIndex: 1,
  ),
  NavDestinationItem(
    icon: Icons.fitness_center_outlined,
    label: 'Gym',
    branchIndex: 2,
  ),
  NavDestinationItem(
    icon: Icons.card_membership_outlined,
    label: 'Plans',
    branchIndex: 3,
  ),
];
