class NavDestinationItem {
  const NavDestinationItem({
    required this.emoji,
    required this.label,
  });

  final String emoji;
  final String label;
}

const List<NavDestinationItem> kNavDestinations = [
  NavDestinationItem(emoji: '🏠', label: 'Home'),
  NavDestinationItem(emoji: '🍱', label: 'Food'),
  NavDestinationItem(emoji: '💪', label: 'Gym'),
];
