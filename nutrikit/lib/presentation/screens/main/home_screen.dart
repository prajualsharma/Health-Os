import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/dashboard.dart';
import '../../../data/models/tracker.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/mock_data.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/common/shimmer_card.dart';
import '../../widgets/home/home_plans_section.dart';
import '../../widgets/home/home_top_bar.dart';
import '../../widgets/home/home_track_food_card.dart';
import '../../widgets/home/home_tracker_list_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DashboardData? _data;
  TrackerSnapshot? _nutrition;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    await context.read<ProfileProvider>().loadProfile();
    try {
      final results = await Future.wait([
        ApiService.instance.getDashboard(),
        ApiService.instance.getTracker(TrackerKind.nutrition),
      ]);
      if (!mounted) return;
      setState(() {
        _data = results[0] as DashboardData;
        _nutrition = results[1] as TrackerSnapshot;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _data = MockData.dashboard();
        _nutrition = MockData.tracker(TrackerKind.nutrition);
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final initials = profile?.initials ?? _data?.initials ?? '…';

    return Container(
      color: AppColors.bg,
      child: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _load,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildBody(initials),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(String initials) {
    if (_loading || _data == null) {
      return const ShimmerList(
        key: ValueKey('loading'),
        count: 3,
        height: 120,
      );
    }

    final d = _data!;
    final proteinPct = d.proteinTarget <= 0
        ? 0.0
        : (d.proteinConsumed / d.proteinTarget) * 100;
    final fatPct =
        d.fatTarget <= 0 ? 0.0 : (d.fatConsumed / d.fatTarget) * 100;
    final carbsPct =
        d.carbTarget <= 0 ? 0.0 : (d.carbsConsumed / d.carbTarget) * 100;

    final profile = context.watch<ProfileProvider>().profile;
    final calorieTarget = profile?.calorieTarget ?? d.calorieTarget;

    return Column(
      key: const ValueKey('content'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeTopBar(
          initials: initials,
          onProfileTap: () => context.push('/profile'),
          onDateTap: () {},
        ),
        const SizedBox(height: 20),
        Text('Your Trackers', style: AppTypography.h1.copyWith(fontSize: 22)),
        const SizedBox(height: 14),
        HomeTrackFoodCard(
          calorieTarget: calorieTarget,
          eatSubtitle: _nutrition?.subtitle,
          proteinPct: proteinPct,
          fatPct: fatPct,
          carbsPct: carbsPct,
        ),
        const SizedBox(height: 12),
        const HomeTrackerListCard(),
        const SizedBox(height: 20),
        const HomePlansSection(),
        const SizedBox(height: 16),
        _todayLogsEmpty(),
      ],
    );
  }

  Widget _todayLogsEmpty() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _logCard(const Color(0xFFFFE4EC), Icons.directions_run_outlined,
                  const Color(0xFF9333EA)),
              const SizedBox(width: 8),
              _logCard(const Color(0xFFFFE8D6), Icons.restaurant_outlined,
                  AppColors.orange),
              const SizedBox(width: 8),
              _logCard(const Color(0xFFDBEAFE), Icons.nightlight_round_outlined,
                  AppColors.blue),
            ],
          ),
          const SizedBox(height: 16),
          Text('Nothing Tracked Yet!', style: AppTypography.h3.copyWith(fontSize: 16)),
          const SizedBox(height: 6),
          Text(
            'Log your meal, workout, water or sleep',
            style: AppTypography.caption,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.go('/home/tracking'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Track Now',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _logCard(Color bg, IconData icon, Color fg) {
    return Container(
      width: 56,
      height: 68,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: fg, size: 26),
    );
  }
}
