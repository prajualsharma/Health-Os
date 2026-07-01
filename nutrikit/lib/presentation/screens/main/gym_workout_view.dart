import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/gym.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/mock_data.dart';
import '../../providers/gym_membership_provider.dart';
import '../../providers/onboarding_store.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/gradient_hero_card.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/gym/achievement_grid.dart';
import '../../widgets/gym/workout_day_card.dart';

class GymWorkoutView extends StatefulWidget {
  const GymWorkoutView({super.key});

  @override
  State<GymWorkoutView> createState() => _GymWorkoutViewState();
}

class _GymWorkoutViewState extends State<GymWorkoutView> {
  static const _weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _calorieTarget = 500;

  List<String> _selectedDays = ['Mon', 'Wed', 'Fri'];
  List<WeeklyWorkoutPlan> _weeks = [];
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

  void _toggleDay(String day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        _selectedDays = _selectedDays.where((d) => d != day).toList();
      } else {
        _selectedDays = [..._selectedDays, day];
      }
    });
  }

  DailyWorkoutPlan? _planForDay(String day) {
    if (MockData.gymDailyPlans.containsKey(day)) {
      return MockData.gymDailyPlans[day];
    }
    if (_weeks.isEmpty) return null;
    for (final d in _weeks.first.days) {
      if (d.dayLabel == day) {
        return DailyWorkoutPlan(
          day: day,
          focus: d.exercises.isNotEmpty ? d.exercises.first.name : 'Workout',
          exercises: d.exercises,
        );
      }
    }
    return null;
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _burnHero(),
        const SizedBox(height: 24),
        if (_selectedDays.isNotEmpty) ...[
          SectionHeader(
            title: 'Your Personalized Plan',
            subtitle: 'AI-generated to burn $_calorieTarget cal/day',
          ),
          const SizedBox(height: 12),
          ..._selectedDays.take(3).map((day) {
            final plan = _planForDay(day);
            if (plan == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: WorkoutDayCard(
                day: plan.day,
                focus: plan.focus,
                exercises: plan.exercises,
                onStart: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Starting ${plan.day}'s workout")),
                  );
                },
              ),
            );
          }),
          if (_selectedDays.length > 3)
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                side: const BorderSide(color: AppColors.cardBorder, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'View All ${_selectedDays.length} Days',
                style: AppTypography.bodyBold.copyWith(color: AppColors.text),
              ),
            ),
          const SizedBox(height: 24),
        ],
        _weeklyProgressCard(),
        const SizedBox(height: 24),
        const AchievementGrid(),
      ],
    );
  }

  Widget _burnHero() {
    return GradientHeroCard(
      gradient: GradientHeroCard.orangeGradient,
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Burn Target',
                      style: AppTypography.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$_calorieTarget',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      'calories per day',
                      style: AppTypography.caption.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_fire_department,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select your workout days:',
                  style: AppTypography.caption.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    for (final day in _weekDays)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: GestureDetector(
                            onTap: () => _toggleDay(day),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: _selectedDays.contains(day)
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                day,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: _selectedDays.contains(day)
                                      ? AppColors.orange
                                      : Colors.white70,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '${_selectedDays.length} days/week · ${_selectedDays.length * _calorieTarget} cal/week total',
                  style: AppTypography.caption.copyWith(
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _weeklyProgressCard() {
    return GradientHeroCard(
      gradient: GradientHeroCard.blueGradient,
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'This Week',
                      style: AppTypography.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const Text(
                      '4 / 5',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'workouts completed',
                      style: AppTypography.caption.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '80%',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _statTile(Icons.timer_outlined, '180', 'Minutes')),
              const SizedBox(width: 10),
              Expanded(
                  child: _statTile(Icons.local_fire_department, '1.4k', 'Calories')),
              const SizedBox(width: 10),
              Expanded(
                  child: _statTile(Icons.trending_up, '+12%', 'Progress')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statTile(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
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
