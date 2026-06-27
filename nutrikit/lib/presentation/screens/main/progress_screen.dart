import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/progress.dart';
import '../../../data/services/api_service.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/app_input.dart';
import '../../widgets/common/error_state.dart';
import '../../widgets/common/shimmer_card.dart';
import 'package:provider/provider.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  ProgressData? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await ApiService.instance.getProgress();
      if (!mounted) return;
      setState(() {
        _data = data;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isWide ? 900 : 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('My Progress', style: AppTypography.h1),
                const SizedBox(height: 16),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _body(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _body() {
    if (_error != null) {
      return SizedBox(
        key: const ValueKey('error'),
        height: 360,
        child: ErrorState(message: _error!, onRetry: _load),
      );
    }
    if (_loading || _data == null) {
      return const ShimmerList(key: ValueKey('loading'), count: 3, height: 140);
    }
    final d = _data!;
    return Column(
      key: const ValueKey('content'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _statCard('${d.currentWeight}', 'Current kg', AppColors.green),
            const SizedBox(width: 12),
            _statCard('${d.kgLost}', 'kg Lost', AppColors.accent),
            const SizedBox(width: 12),
            _statCard('${d.weekStreak}', 'Week Streak', AppColors.orange),
          ],
        ),
        const SizedBox(height: 16),
        _weightChart(d),
        const SizedBox(height: 14),
        _adherenceCard(d),
        const SizedBox(height: 14),
        _logWeightCard(d),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _statCard(String value, String label, Color color) {
    return Expanded(
      child: AppCard(
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                  color: color,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                )),
            const SizedBox(height: 2),
            Text(label, style: AppTypography.caption),
          ],
        ),
      ),
    );
  }

  Widget _weightChart(ProgressData d) {
    final minW = d.weights.map((e) => e.weight).reduce((a, b) => a < b ? a : b);
    final maxW = d.weights.map((e) => e.weight).reduce((a, b) => a > b ? a : b);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weight Over Time (kg)', style: AppTypography.bodyBold),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                minY: (minW - 2).floorToDouble(),
                maxY: (maxW + 1).ceilToDouble(),
                alignment: BarChartAlignment.spaceAround,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= d.weights.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            d.weights[i].label,
                            style: const TextStyle(
                                color: AppColors.muted, fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppColors.surface,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toStringAsFixed(1)} kg',
                        const TextStyle(
                          color: AppColors.green,
                          fontWeight: FontWeight.w800,
                        ),
                      );
                    },
                  ),
                ),
                barGroups: [
                  for (int i = 0; i < d.weights.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: d.weights[i].weight,
                          width: 18,
                          borderRadius: BorderRadius.circular(6),
                          gradient: i == d.weights.length - 1
                              ? AppColors.greenGradient
                              : null,
                          color: i == d.weights.length - 1
                              ? null
                              : AppColors.green.withValues(alpha: 0.35),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _adherenceCard(ProgressData d) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly Adherence', style: AppTypography.bodyBold),
          const SizedBox(height: 14),
          ...d.adherence.map((a) {
            final Color color = a.pct >= 90
                ? AppColors.green
                : a.pct >= 70
                    ? AppColors.accent
                    : a.pct > 0
                        ? AppColors.orange
                        : AppColors.muted;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 28,
                    child: Text(a.day, style: AppTypography.caption),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: a.pct / 100,
                        minHeight: 8,
                        backgroundColor: AppColors.surface,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 32,
                    child: Text(
                      '${a.pct}%',
                      textAlign: TextAlign.right,
                      style: AppTypography.caption,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _logWeightCard(ProgressData d) {
    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Log Today's Weight", style: AppTypography.bodyBold),
                const SizedBox(height: 2),
                Text('Last: ${d.lastLoggedWeight} kg (yesterday)',
                    style: AppTypography.caption),
              ],
            ),
          ),
          AppButton(
            label: 'Log +',
            variant: ButtonVariant.secondary,
            width: 90,
            onPressed: _showLogSheet,
          ),
        ],
      ),
    );
  }

  void _showLogSheet() {
    final controller = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Log Today's Weight", style: AppTypography.h3),
              const SizedBox(height: 16),
              AppInput(
                label: 'Weight (kg)',
                placeholder: '76.0',
                controller: controller,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              AppButton(
                label: 'Save',
                onPressed: () {
                  final w = double.tryParse(controller.text);
                  if (w != null) {
                    context.read<ProfileProvider>().logWeight(w);
                    _load();
                  }
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
