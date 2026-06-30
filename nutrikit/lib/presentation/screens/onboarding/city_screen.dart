import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../onboarding/onboarding_flow.dart';
import '../../providers/onboarding_store.dart';
import '../../widgets/onboarding/onboarding_city_grid.dart';
import '../../widgets/onboarding/onboarding_scaffold.dart';

class CityScreen extends StatefulWidget {
  const CityScreen({super.key});

  @override
  State<CityScreen> createState() => _CityScreenState();
}

class _CityScreenState extends State<CityScreen> {
  String? _selected;
  final _search = TextEditingController();

  static const _cities = [
    OnboardingCityOption(name: 'New York'),
    OnboardingCityOption(name: 'San Francisco'),
    OnboardingCityOption(name: 'Los Angeles'),
    OnboardingCityOption(name: 'Chicago'),
    OnboardingCityOption(name: 'Toronto'),
    OnboardingCityOption(name: 'Bengaluru'),
    OnboardingCityOption(name: 'Mumbai'),
    OnboardingCityOption(name: 'New Delhi'),
    OnboardingCityOption(name: 'Kuala Lumpur'),
    OnboardingCityOption(name: 'Singapore'),
    OnboardingCityOption(name: 'Dubai'),
    OnboardingCityOption(name: 'Jakarta'),
  ];

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _continue() {
    if (_selected == null) return;
    OnboardingStore.instance.update((d) => d.copyWith(city: _selected!));
    context.push(OnboardingFlow.nextPath('/onboarding/city')!);
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      routePath: '/onboarding/city',
      title: 'Where are you from?',
      subtitle: 'This will help us personalize the app for you.',
      nextEnabled: _selected != null,
      onNext: _continue,
      body: Column(
        children: [
          TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search for your city',
              hintStyle: AppTypography.caption.copyWith(fontSize: 14),
              filled: true,
              fillColor: AppColors.card,
              suffixIcon: const Icon(Icons.search, color: AppColors.dim),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: const BorderSide(color: AppColors.cardBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: const BorderSide(color: AppColors.cardBorder),
              ),
            ),
          ),
          const SizedBox(height: 20),
          OnboardingCityGrid(
            cities: _cities,
            selected: _selected,
            searchQuery: _search.text,
            onSelect: (c) => setState(() => _selected = c),
          ),
        ],
      ),
    );
  }
}
