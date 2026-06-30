import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/user_profile.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/common/app_avatar.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/error_state.dart';
import '../../widgets/common/shimmer_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadProfile();
    });
  }

  Future<void> _load() => context.read<ProfileProvider>().loadProfile();

  Future<void> _logout() async {
    context.read<ProfileProvider>().clear();
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    context.go('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    final canPop = context.canPop();
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: canPop
          ? AppBar(
              backgroundColor: AppColors.bg,
              foregroundColor: AppColors.text,
              elevation: 0,
              title: const Text('Profile'),
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isWide ? 800 : 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!canPop) ...[
                    Text('Profile', style: AppTypography.h1),
                    const SizedBox(height: 16),
                  ],
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _body(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _body() {
    final prov = context.watch<ProfileProvider>();
    if (prov.error != null) {
      return SizedBox(
        key: const ValueKey('error'),
        height: 360,
        child: ErrorState(message: prov.error!, onRetry: _load),
      );
    }
    if (prov.isLoading && prov.profile == null) {
      return const ShimmerList(key: ValueKey('loading'), count: 3, height: 120);
    }
    final p = prov.profile;
    if (p == null) {
      return const ShimmerList(key: ValueKey('loading'), count: 3, height: 120);
    }
    return Column(
      key: const ValueKey('content'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _headerCard(p),
        const SizedBox(height: 14),
        _statsCard(p),
        const SizedBox(height: 14),
        _menu(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _headerCard(UserProfile p) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.green.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          AppAvatar(initials: p.initials, size: 60, accent: true),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name, style: AppTypography.h2),
                const SizedBox(height: 2),
                Text(p.email, style: AppTypography.caption),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '🔥 ${p.goal}',
                    style: const TextStyle(
                      color: AppColors.green,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsCard(UserProfile p) {
    final rows = [
      ['Current Weight', '${p.currentWeight} kg'],
      ['Target Weight', '${p.targetWeight} kg'],
      ['Height', '${p.height} cm'],
      ['Daily Target', '${p.calorieTarget} kcal'],
      ['Plan', p.plan.isEmpty ? 'NutriKit' : p.plan],
    ];
    return AppCard(
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(rows[i][0], style: AppTypography.caption),
                Text(rows[i][1], style: AppTypography.bodyBold),
              ],
            ),
            if (i != rows.length - 1)
              const Divider(color: AppColors.cardBorder, height: 20),
          ],
        ],
      ),
    );
  }

  Widget _menu() {
    final items = [
      ['📦', 'Order History', false],
      ['🔔', 'Notifications', false],
      ['🏋️', 'My Gym', false],
      ['🛡️', 'Privacy & Terms', false],
      ['🚪', 'Logout', true],
    ];
    return Column(
      children: items.map((item) {
        final isLogout = item[2] as bool;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AppCard(
            onTap: isLogout ? _logout : () {},
            child: Row(
              children: [
                Text(item[0] as String, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    item[1] as String,
                    style: AppTypography.bodyBold.copyWith(
                      color: isLogout ? AppColors.red : AppColors.text,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.muted),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
