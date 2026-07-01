import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/tracker.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/mock_data.dart';

class HomeTrackerListCard extends StatefulWidget {
  const HomeTrackerListCard({super.key});

  @override
  State<HomeTrackerListCard> createState() => _HomeTrackerListCardState();
}

class _HomeTrackerListCardState extends State<HomeTrackerListCard> {
  bool _expanded = true;
  bool _loading = true;
  final Map<TrackerKind, TrackerSnapshot> _trackers = {};

  static const _kinds = [
    TrackerKind.weight,
    TrackerKind.workout,
    TrackerKind.steps,
    TrackerKind.sleep,
    TrackerKind.water,
  ];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final results = await Future.wait(
      _kinds.map((k) async {
        try {
          return MapEntry(k, await ApiService.instance.getTracker(k));
        } catch (_) {
          return MapEntry(k, MockData.tracker(k));
        }
      }),
    );
    if (!mounted) return;
    setState(() {
      _trackers
        ..clear()
        ..addEntries(results);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          _buildRow(TrackerKind.weight,
              Icons.monitor_weight_outlined, AppColors.surface, AppColors.muted),
          _divider(),
          _buildRow(TrackerKind.workout, Icons.local_fire_department_outlined,
              const Color(0xFFF3E8FF), const Color(0xFF9333EA),
              onTap: () => context.go('/home/gym')),
          _divider(),
          _buildRow(TrackerKind.steps, Icons.directions_walk_outlined,
              const Color(0xFFF3E8FF), const Color(0xFF7C3AED)),
          if (_expanded) ...[
            _divider(),
            _buildRow(TrackerKind.sleep, Icons.nightlight_round_outlined,
                const Color(0xFFE0F2FE), AppColors.blue),
            _divider(),
            _buildRow(TrackerKind.water, Icons.water_drop_outlined,
                const Color(0xFFE0F2FE), AppColors.blue),
            _divider(),
            _row(
              icon: Icons.add,
              tint: AppColors.primarySoft,
              iconColor: AppColors.primary,
              title: 'Track More',
              subtitle: '',
              titleOnly: true,
              trailing: const Icon(Icons.chevron_right, color: AppColors.muted),
              onTap: () => context.go('/home/tracking'),
            ),
          ],
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: AnimatedRotation(
                turns: _expanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 250),
                child: const Icon(Icons.keyboard_arrow_down, color: AppColors.muted),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    TrackerKind kind,
    IconData icon,
    Color tint,
    Color iconColor, {
    VoidCallback? onTap,
  }) {
    final t = _trackers[kind]!;
    final trailing = t.action == TrackerAction.navigate
        ? const Icon(Icons.chevron_right, color: AppColors.muted)
        : _plusButton(onTap ?? () {});
    return _row(
      icon: icon,
      tint: tint,
      iconColor: iconColor,
      title: t.title,
      subtitle: t.subtitle,
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _divider() => const Divider(height: 1, color: AppColors.cardBorder);

  Widget _plusButton(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.cardBorder),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.add, size: 18, color: AppColors.muted),
      ),
    );
  }

  Widget _row({
    required IconData icon,
    required Color tint,
    required String title,
    required String subtitle,
    required Widget trailing,
    Color iconColor = AppColors.muted,
    bool titleOnly = false,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.bodyBold.copyWith(fontSize: 15)),
                    if (!titleOnly && subtitle.isNotEmpty)
                      Text(subtitle, style: AppTypography.caption),
                  ],
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}
