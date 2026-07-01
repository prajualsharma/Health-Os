import 'package:flutter/material.dart';

import '../../../core/theme/app_typography.dart';
import '../../../core/theme/cafe_colors.dart';
import '../../../data/models/order.dart';
import '../../widgets/cafe/cafe_add_button.dart';

class CafeDeliveryCard extends StatelessWidget {
  const CafeDeliveryCard({
    super.key,
    required this.items,
    required this.onIncrement,
    required this.onDecrement,
  });

  final List<OrderItem> items;
  final ValueChanged<String> onIncrement;
  final ValueChanged<String> onDecrement;

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<OrderItem>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.id, () => []).add(item);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CafeColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: CafeColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.access_time, color: CafeColors.accentGreen, size: 20),
              const SizedBox(width: 8),
              Text('Delivery in 15 minutes',
                  style: AppTypography.bodyBold.copyWith(fontSize: 15)),
            ],
          ),
          Text(
            '${items.length} item${items.length == 1 ? '' : 's'}',
            style: AppTypography.caption.copyWith(fontSize: 11),
          ),
          const SizedBox(height: 14),
          ...grouped.entries.map((e) => _itemRow(e.value.first, e.value.length)),
          const SizedBox(height: 8),
          Center(
            child: Text(
              '+ Add more items',
              style: TextStyle(
                color: CafeColors.accentGreen,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemRow(OrderItem item, int qty) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: CafeColors.sectionBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(item.emoji, style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: AppTypography.bodyBold.copyWith(fontSize: 14)),
                Text(
                  '${item.portion} · ${item.calories} cal',
                  style: AppTypography.caption.copyWith(fontSize: 11),
                ),
                Row(
                  children: [
                    Icon(Icons.access_time,
                        size: 12, color: CafeColors.accentGreen),
                    Text(
                      ' 15 mins',
                      style: TextStyle(
                        color: CafeColors.accentGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CafeQuantityStepper(
                quantity: qty,
                onDecrement: () => onDecrement(item.id),
                onIncrement: () => onIncrement(item.id),
              ),
              const SizedBox(height: 6),
              Text(
                '₹${(item.price * qty).toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CafeSustainabilityCard extends StatelessWidget {
  const CafeSustainabilityCard({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CafeColors.card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: CafeColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: CafeColors.sectionBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.restaurant, color: CafeColors.accentGreen, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Don't send cutlery, tissues & straws",
                  style: AppTypography.bodyBold.copyWith(fontSize: 13),
                ),
                Text(
                  'Choose sustainability: skip the extras',
                  style: AppTypography.caption.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          Checkbox(
            value: value,
            onChanged: (v) => onChanged(v ?? false),
            activeColor: CafeColors.accentGreen,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ],
      ),
    );
  }
}

class CafeOffersCard extends StatelessWidget {
  const CafeOffersCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CafeColors.badgeBlueBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: CafeColors.badgeBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Yay! You got FREE Delivery',
                  style: TextStyle(
                    color: CafeColors.badgeBlue,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'No coupon needed',
                  style: AppTypography.caption.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            'See all coupons →',
            style: TextStyle(
              color: CafeColors.badgeBlue,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class CafeTipCard extends StatelessWidget {
  const CafeTipCard({
    super.key,
    required this.selectedTip,
    required this.onTipSelected,
  });

  final int? selectedTip;
  final ValueChanged<int?> onTipSelected;

  static const _tips = [(20, '😄'), (30, '🤩'), (50, '😍')];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CafeColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: CafeColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tip your delivery partner', style: AppTypography.bodyBold),
          const SizedBox(height: 4),
          Text(
            'Your kindness means a lot! 100% of your tip goes directly to your delivery partner.',
            style: AppTypography.caption.copyWith(fontSize: 11),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (final (amount, emoji) in _tips) ...[
                Expanded(child: _tipBtn(amount, emoji)),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: GestureDetector(
                  onTap: () => onTipSelected(null),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: CafeColors.border),
                    ),
                    child: const Column(
                      children: [
                        Text('👏', style: TextStyle(fontSize: 16)),
                        Text('Custom',
                            style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tipBtn(int amount, String emoji) {
    final sel = selectedTip == amount;
    return GestureDetector(
      onTap: () => onTipSelected(sel ? null : amount),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: sel ? CafeColors.accentGreen : CafeColors.border,
            width: sel ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            Text(
              '₹$amount',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: sel ? CafeColors.accentGreen : CafeColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CafeDonationRow extends StatelessWidget {
  const CafeDonationRow({
    super.key,
    required this.added,
    required this.onToggle,
  });

  final bool added;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Donation amount', style: AppTypography.bodyBold.copyWith(fontSize: 13)),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: CafeColors.border, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('₹2', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onToggle,
                child: Text(
                  added ? 'Remove' : 'Add',
                  style: TextStyle(
                    color: CafeColors.accentGreen,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CafeCancellationPolicy extends StatelessWidget {
  const CafeCancellationPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CafeColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cancellation Policy', style: AppTypography.bodyBold),
          const SizedBox(height: 6),
          Text(
            'Orders cannot be cancelled once dish preparation starts. In case of unexpected delays, a refund will be provided, if applicable.',
            style: AppTypography.caption.copyWith(fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class CafeDeliveryInstructions extends StatefulWidget {
  const CafeDeliveryInstructions({super.key});

  @override
  State<CafeDeliveryInstructions> createState() =>
      _CafeDeliveryInstructionsState();
}

class _CafeDeliveryInstructionsState extends State<CafeDeliveryInstructions> {
  final _selected = <int>{1, 2};

  static const _options = [
    (Icons.mic, 'Record', 'Tap here and hold'),
    (Icons.phone_disabled_outlined, 'Avoid calling', ''),
    (Icons.doorbell, "Don't ring the bell", ''),
    (Icons.door_front_door_outlined, 'Leave at door', ''),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Delivery instructions', style: AppTypography.h3),
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _options.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final (icon, label, sub) = _options[i];
                final sel = _selected.contains(i);
                return GestureDetector(
                  onTap: () => setState(() {
                    if (sel) {
                      _selected.remove(i);
                    } else {
                      _selected.add(i);
                    }
                  }),
                  child: Container(
                    width: 90,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: CafeColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: sel ? CafeColors.accentGreen : CafeColors.border,
                        width: sel ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon,
                            size: 22,
                            color: sel
                                ? CafeColors.accentGreen
                                : CafeColors.muted),
                        const SizedBox(height: 4),
                        Text(
                          label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: sel
                                ? CafeColors.accentGreen
                                : CafeColors.text,
                          ),
                        ),
                        if (sub.isNotEmpty)
                          Text(
                            sub,
                            textAlign: TextAlign.center,
                            style: AppTypography.caption.copyWith(fontSize: 8),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
