import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/order.dart';
import '../../../data/services/api_service.dart';
import '../../providers/cart_store.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/app_input.dart';
import '../../widgets/common/empty_state.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  static const _slots = ['12–1 PM', '1–2 PM', '7–8 PM', '8–9 PM'];
  static const double _delivery = 29;
  static const double _discount = 50;

  String _slot = '7–8 PM';
  final _address = TextEditingController(
      text: '42 Green Avenue, Koramangala, Bengaluru 560034');
  bool _loading = false;

  final CartStore _cart = CartStore.instance;

  @override
  void initState() {
    super.initState();
    _cart.seedIfEmpty(const [
      OrderItem(
        id: 'm2',
        name: 'Grilled Chicken Rice',
        emoji: '🍗',
        portion: '420g',
        calories: 520,
        price: 249,
      ),
      OrderItem(
        id: 'm4',
        name: 'Salmon & Quinoa',
        emoji: '🐟',
        portion: '380g',
        calories: 480,
        price: 329,
      ),
    ]);
  }

  @override
  void dispose() {
    _address.dispose();
    super.dispose();
  }

  double get _subtotal => _cart.subtotal;
  double get _total => (_subtotal + _delivery - _discount).clamp(0, double.infinity);

  Future<void> _pay() async {
    setState(() => _loading = true);
    try {
      await ApiService.instance.placeOrder(OrderRequest(
        itemIds: _cart.items.map((e) => e.id).toList(),
        slot: _slot,
        address: _address.text,
        total: _total,
      ));
      if (!mounted) return;
      context.go('/order-confirm');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: AppColors.red, content: Text(e.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('My Order')),
      body: AnimatedBuilder(
        animation: _cart,
        builder: (context, _) {
          if (_cart.items.isEmpty) {
            return EmptyState(
              emoji: '🛒',
              title: 'Your cart is empty',
              subtitle: 'Add meals from the kitchen to get started',
              actionLabel: 'Browse Food',
              onAction: () => context.go('/home/food'),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ..._cart.items.map(_orderItem),
                    const SizedBox(height: 12),
                    _slotPicker(),
                    const SizedBox(height: 12),
                    _addressCard(),
                    const SizedBox(height: 12),
                    _billSummary(),
                    const SizedBox(height: 18),
                    AppButton(
                      label: 'Pay ₹${_total.toStringAsFixed(0)} via UPI 💸',
                      isLoading: _loading,
                      onPressed: _pay,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _orderItem(OrderItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(item.emoji, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: AppTypography.bodyBold),
                  const SizedBox(height: 2),
                  Text('${item.portion} · ${item.calories} cal',
                      style: AppTypography.caption),
                ],
              ),
            ),
            Text('₹${item.price.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: AppColors.green,
                  fontWeight: FontWeight.w800,
                )),
          ],
        ),
      ),
    );
  }

  Widget _slotPicker() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Delivery Slot', style: AppTypography.bodyBold),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _slots.map((s) {
              final selected = s == _slot;
              return GestureDetector(
                onTap: () => setState(() => _slot = s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color:
                        selected ? AppColors.greenGlow : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          selected ? AppColors.green : AppColors.cardBorder,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    s,
                    style: TextStyle(
                      color: selected ? AppColors.green : AppColors.text,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _addressCard() {
    return AppCard(
      child: AppInput(
        label: 'Delivery Address',
        placeholder: 'Enter your address',
        controller: _address,
      ),
    );
  }

  Widget _billSummary() {
    return AppCard(
      child: Column(
        children: [
          _billRow('Subtotal', '₹${_subtotal.toStringAsFixed(0)}'),
          const SizedBox(height: 8),
          _billRow('Delivery', '₹${_delivery.toStringAsFixed(0)}'),
          const SizedBox(height: 8),
          _billRow('Discount', '-₹${_discount.toStringAsFixed(0)}',
              valueColor: AppColors.green),
          const Divider(color: AppColors.cardBorder, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: AppTypography.bodyBold),
              Text(
                '₹${_total.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: AppColors.green,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _billRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.caption),
        Text(value,
            style: TextStyle(
              color: valueColor ?? AppColors.text,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            )),
      ],
    );
  }
}
