import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/gym.dart';
import '../../../data/services/api_service.dart';
import '../../providers/gym_membership_provider.dart';
import '../../providers/onboarding_store.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_card.dart';

class GymWorkoutView extends StatefulWidget {
  const GymWorkoutView({super.key});

  @override
  State<GymWorkoutView> createState() => _GymWorkoutViewState();
}

class _GymWorkoutViewState extends State<GymWorkoutView> {
  List<WeeklyWorkoutPlan> _weeks = [];
  int _selectedWeek = 0;
  final Map<String, bool> _done = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final goal = OnboardingStore.instance.data.goal.isNotEmpty
        ? OnboardingStore.instance.data.goal
        : 'Lose Weight';
    final weeks = await ApiService.instance.getWeeklyWorkoutPlan(goal);
    if (!mounted) return;
    setState(() {
      _weeks = weeks;
      _loading = false;
    });
  }

  void _toggle(String id) {
    setState(() => _done[id] = !(_done[id] ?? false));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(color: AppColors.green),
        ),
      );
    }
    if (_weeks.isEmpty) return const SizedBox.shrink();

    final week = _weeks[_selectedWeek];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your workout plan', style: AppTypography.h3),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_weeks.length, (i) {
              final selected = i == _selectedWeek;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedWeek = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color:
                          selected ? AppColors.greenGlow : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            selected ? AppColors.green : AppColors.cardBorder,
                      ),
                    ),
                    child: Text(
                      'Week ${i + 1}',
                      style: TextStyle(
                        color: selected ? AppColors.green : AppColors.muted,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 8),
        Text(week.title, style: AppTypography.caption),
        const SizedBox(height: 14),
        ...week.days.map(_dayCard),
      ],
    );
  }

  Widget _dayCard(WorkoutDay day) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(day.dayLabel, style: AppTypography.bodyBold),
            const SizedBox(height: 10),
            ...day.exercises.map((e) => _exerciseRow(e)),
          ],
        ),
      ),
    );
  }

  Widget _exerciseRow(WorkoutExercise e) {
    final done = _done[e.id] ?? e.done;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.name, style: AppTypography.bodyBold),
                Text('${e.detail} · ~${e.caloriesBurn} kcal burn',
                    style: AppTypography.caption),
              ],
            ),
          ),
          Switch(
            value: done,
            activeThumbColor: AppColors.green,
            onChanged: (_) => _toggle(e.id),
          ),
        ],
      ),
    );
  }
}

class GymPartnersView extends StatefulWidget {
  const GymPartnersView({super.key});

  @override
  State<GymPartnersView> createState() => _GymPartnersViewState();
}

class _GymPartnersViewState extends State<GymPartnersView> {
  List<PartnerGym> _gyms = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final gyms = await ApiService.instance.getPartnerGyms();
    if (!mounted) return;
    setState(() {
      _gyms = gyms;
      _loading = false;
    });
  }

  Future<void> _join(PartnerGym gym) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Join partner gym?'),
        content: Text(
          'You\'ll be added to ${gym.name} on HealthOS. Your trainer will see your NutriKit goal.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Join'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await context.read<GymMembershipProvider>().joinGym(
          gymId: gym.id,
          trainerName: gym.assignedTrainer,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Trainer will see your NutriKit goal')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final membership = context.watch<GymMembershipProvider>();
    PartnerGym? linked;
    if (membership.hasLinkedGym) {
      for (final g in _gyms) {
        if (g.id == membership.linkedGymId) {
          linked = g;
          break;
        }
      }
    }
    final r = OnboardingStore.instance.result;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Partner gyms', style: AppTypography.h3),
        const SizedBox(height: 10),
        if (membership.hasLinkedGym && linked != null) ...[
          _trainerCard(linked, membership.assignedTrainerName ?? linked.assignedTrainer),
          _goalCard(r?.calorieTarget ?? 1840, r?.proteinTarget ?? 145),
          const SizedBox(height: 16),
        ],
        if (_loading)
          const Center(child: CircularProgressIndicator(color: AppColors.green))
        else
          ..._gyms.map((g) => _gymCard(g, membership.linkedGymId == g.id)),
      ],
    );
  }

  Widget _trainerCard(PartnerGym gym, String trainer) {
    return AppCard(
      child: Row(
        children: [
          Text(gym.emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.greenGlow,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'HealthOS Partner',
                    style: TextStyle(
                      color: AppColors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text('Assigned trainer', style: AppTypography.caption),
                Text(trainer, style: AppTypography.bodyBold),
                Text(gym.name, style: AppTypography.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _goalCard(int calories, int protein) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your goal (trainer view)', style: AppTypography.bodyBold),
            const SizedBox(height: 8),
            Text('$calories kcal/day · ${protein}g protein',
                style: AppTypography.body.copyWith(color: AppColors.green)),
            const SizedBox(height: 4),
            Text('Weekly burn target: ~1,400 kcal',
                style: AppTypography.caption),
          ],
        ),
      ),
    );
  }

  Widget _gymCard(PartnerGym gym, bool joined) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(gym.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(gym.name, style: AppTypography.bodyBold),
                      Text(
                        '${gym.area} · ${gym.distanceKm} km · ⭐ ${gym.rating}',
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ),
                if (gym.isPartner)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.greenGlow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Partner',
                      style: TextStyle(
                        color: AppColors.green,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(gym.offerText, style: AppTypography.caption),
            const SizedBox(height: 12),
            AppButton(
              label: joined ? 'Joined ✓' : 'Join gym',
              variant:
                  joined ? ButtonVariant.secondary : ButtonVariant.primary,
              onPressed: joined ? null : () => _join(gym),
            ),
          ],
        ),
      ),
    );
  }
}
