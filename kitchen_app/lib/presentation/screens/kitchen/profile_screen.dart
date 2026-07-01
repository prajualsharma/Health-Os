import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/kitchen_store.dart';
import '../../widgets/kitchen/bistro_card.dart';

class KitchenProfileScreen extends StatelessWidget {
  const KitchenProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<KitchenStore>();
    final kitchen = store.selected;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 88,
            backgroundColor: AppColors.headerDark,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.headerGradient,
                ),
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: const Text(
                  'Store',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                BistroCard(
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.storefront,
                            color: AppColors.primaryDark),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              kitchen?.name ?? 'Kitchen',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              [kitchen?.address, kitchen?.city]
                                  .where((e) => e != null && e.isNotEmpty)
                                  .join(', '),
                              style: const TextStyle(
                                color: AppColors.muted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                _tile(
                  icon: Icons.swap_horiz,
                  label: 'Switch to corporate view',
                  onTap: () async {
                    await context
                        .read<AuthProvider>()
                        .setRole(SessionRole.corporate);
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
              ]),
            ),
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
    return BistroCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.zero,
      child: ListTile(
        leading: Icon(icon, color: color ?? AppColors.primaryDark),
        title: Text(
          label,
          style: TextStyle(
            color: color ?? AppColors.text,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.dim),
        onTap: onTap,
      ),
    );
  }
}
