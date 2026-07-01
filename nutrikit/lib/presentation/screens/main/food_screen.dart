import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/food/food_delivery_header.dart';
import '../../widgets/food/food_nutriplan_view.dart';
import 'food_cook_view.dart';
import 'food_order_view.dart';

enum FoodSegment { nutriplan, cafe, recipes }

FoodSegment? foodSegmentFromQuery(String? value) => switch (value) {
      'nutriplan' => FoodSegment.nutriplan,
      'cafe' => FoodSegment.cafe,
      'recipes' => FoodSegment.recipes,
      'plan' => FoodSegment.nutriplan,
      'tomorrow' => FoodSegment.nutriplan,
      'order' => FoodSegment.cafe,
      'addons' => FoodSegment.cafe,
      'cook' => FoodSegment.recipes,
      _ => null,
    };

class FoodScreen extends StatefulWidget {
  const FoodScreen({super.key, this.initialSegment});

  final FoodSegment? initialSegment;

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  late FoodSegment _segment;

  @override
  void initState() {
    super.initState();
    _segment = widget.initialSegment ?? FoodSegment.cafe;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadProfile();
    });
  }

  @override
  void didUpdateWidget(covariant FoodScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSegment != null &&
        widget.initialSegment != oldWidget.initialSegment) {
      _segment = widget.initialSegment!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FoodDeliveryHeader(
          segment: _segment,
          onSegmentChanged: (s) => setState(() => _segment = s),
          onSearchTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Search in ${_segment.name} coming soon')),
            );
          },
        ),
        Expanded(
          child: ColoredBox(
            color: _segment == FoodSegment.cafe
                ? const Color(0xFFF7F8FA)
                : AppColors.bg,
            child: _segmentBody(),
          ),
        ),
      ],
    );
  }

  Widget _segmentBody() {
    return switch (_segment) {
      FoodSegment.nutriplan => const FoodNutriplanView(),
      FoodSegment.cafe => const FoodOrderView(isAddOnsContext: true),
      FoodSegment.recipes => const FoodCookView(),
    };
  }
}
