import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/kitchen_store.dart';

class KitchenProfileScreen extends StatelessWidget {
  const KitchenProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<KitchenStore>();
    final kitchen = store.selected;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.soup_kitchen, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(kitchen?.name ?? 'Kitchen',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text(
                        [kitchen?.address, kitchen?.city]
                            .where((e) => e != null && e.isNotEmpty)
                            .join(', '),
                        style: const TextStyle(
                            color: AppColors.muted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _tile(
            icon: Icons.swap_horiz,
            label: 'Switch to corporate view',
            onTap: () async {
              await context.read<AuthProvider>().setRole(SessionRole.corporate);
              if (context.mounted) context.go('/corporate');
            },
          ),
          _tile(
            icon: Icons.refresh,
            label: 'Refresh board',
            onTap: () => store.refreshBoard(),
          ),
          _tile(
            icon: Icons.logout,
            label: 'Logout',
            color: AppColors.danger,
            onTap: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: ListTile(
        leading: Icon(icon, color: color ?? AppColors.text),
        title: Text(label, style: TextStyle(color: color ?? AppColors.text)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.dim),
        onTap: onTap,
      ),
    );
  }
}
