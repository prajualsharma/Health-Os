import 'package:flutter/material.dart';

import '../../screens/main/food_screen.dart';
import 'delivery_header_search_row.dart';
import 'delivery_header_top_bar.dart';
import 'delivery_segment_tabs.dart';

class FoodDeliveryHeader extends StatelessWidget {
  const FoodDeliveryHeader({
    super.key,
    required this.segment,
    required this.onSegmentChanged,
    this.eta = '25 mins',
    this.onSearchTap,
  });

  final FoodSegment segment;
  final ValueChanged<FoodSegment> onSegmentChanged;
  final String eta;
  final VoidCallback? onSearchTap;

  static const _headerTop = Color(0xFF1A4F48);
  static const _headerBottom = Color(0xFF123832);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_headerTop, _headerBottom],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DeliveryHeaderTopBar(eta: eta),
            DeliverySegmentTabs(
              segment: segment,
              onSegmentChanged: onSegmentChanged,
            ),
            DeliveryHeaderSearchRow(
              segment: segment,
              onSearchTap: onSearchTap,
            ),
          ],
        ),
      ),
    );
  }
}
