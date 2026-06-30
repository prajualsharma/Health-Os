import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class OnboardingCityOption {
  const OnboardingCityOption({required this.name, this.icon = Icons.location_city});

  final String name;
  final IconData icon;
}

class OnboardingCityGrid extends StatelessWidget {
  const OnboardingCityGrid({
    super.key,
    required this.cities,
    required this.selected,
    required this.onSelect,
    this.searchQuery = '',
  });

  final List<OnboardingCityOption> cities;
  final String? selected;
  final ValueChanged<String> onSelect;
  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    final filtered = searchQuery.isEmpty
        ? cities
        : cities
            .where((c) =>
                c.name.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, i) {
        final city = filtered[i];
        final isSelected = selected == city.name;
        return GestureDetector(
          onTap: () => onSelect(city.name),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primarySoft : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  city.icon,
                  size: 32,
                  color: isSelected ? AppColors.primary : AppColors.text,
                ),
                const SizedBox(height: 8),
                Text(
                  city.name,
                  style: AppTypography.caption.copyWith(
                    fontSize: 11,
                    color: AppColors.text,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
