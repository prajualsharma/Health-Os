import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../providers/kitchen_store.dart';
import 'menu_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';

class KitchenShell extends StatefulWidget {
  const KitchenShell({super.key});

  @override
  State<KitchenShell> createState() => _KitchenShellState();
}

class _KitchenShellState extends State<KitchenShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KitchenStore>().ensureSelected();
    });
  }

  @override
  Widget build(BuildContext context) {
    final newCount = context.select<KitchenStore, int>((s) => s.newCount);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: IndexedStack(
        index: _index,
        children: const [
          OrdersScreen(),
          MenuScreen(),
          KitchenProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: Badge(
              isLabelVisible: newCount > 0,
              backgroundColor: AppColors.danger,
              label: Text('$newCount'),
              child: const Icon(Icons.receipt_long_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: newCount > 0,
              backgroundColor: AppColors.danger,
              label: Text('$newCount'),
              child: const Icon(Icons.receipt_long),
            ),
            label: 'Orders',
          ),
          const NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Stock',
          ),
          const NavigationDestination(
            icon: Icon(Icons.store_outlined),
            selectedIcon: Icon(Icons.store),
            label: 'Store',
          ),
        ],
      ),
    );
  }
}
