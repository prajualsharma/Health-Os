import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/cafe_colors.dart';
import '../../../data/models/order.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/mock_data.dart';
import '../../providers/cart_store.dart';
import '../../providers/onboarding_store.dart';
import '../../widgets/cafe/cafe_checkout_bill.dart';
import '../../widgets/cafe/cafe_checkout_footer.dart';
import '../../widgets/cafe/cafe_product_card.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/app_input.dart';
import '../../widgets/common/empty_state.dart';
import 'cafe_checkout_sections.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key, this.isCafeCheckout = false});

  final bool isCafeCheckout;

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
  bool _skipCutlery = false;
  int? _tip;
  bool _donationAdded = false;

  final CartStore _cart = CartStore.instance;

  @override
  void initState() {
    super.initState();
    if (!widget.isCafeCheckout) {
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
  }

  @override
  void dispose() {
    _address.dispose();
    super.dispose();
  }

  double get _subtotal => _cart.subtotal;
  double get _cafeConvenience => widget.isCafeCheckout ? 9 : 0;
  double get _cafeDelivery => widget.isCafeCheckout ? 0 : _delivery;
  double get _cafeDiscount => widget.isCafeCheckout ? 0 : _discount;
  double get _tipAmount => _tip?.toDouble() ?? 0;
  double get _donationAmount => _donationAdded ? 2 : 0;
  double get _cafeOriginalTotal => _subtotal * 1.1;
  double get _cafeSavings =>
      (_cafeOriginalTotal - _subtotal + (widget.isCafeCheckout ? 25 : 0))
          .clamp(0, double.infinity);
  double get _total => (_subtotal +
          _cafeDelivery -
          _cafeDiscount +
          _cafeConvenience +
          _tipAmount +
          _donationAmount)
      .clamp(0, double.infinity);

  String get _displayAddress {
    final city = OnboardingStore.instance.data.city;
    if (city.isNotEmpty) {
      return 'Floor 4, Flat number 401, $city';
    }
    return 'Floor 4, Flat number 401 Sujana Nagar, Devara Jee...';
  }

  Future<void> _pay() async {
    setState(() => _loading = true);
    try {
      await ApiService.instance.placeOrder(OrderRequest(
        itemIds: _cart.items.map((e) => e.id).toList(),
        slot: widget.isCafeCheckout ? 'ASAP' : _slot,
        address: widget.isCafeCheckout ? _displayAddress : _address.text,
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
    if (widget.isCafeCheckout) {
      return _cafeCheckoutScaffold();
    }
    return _legacyCheckoutScaffold();
  }

  Widget _cafeCheckoutScaffold() {
    return Scaffold(
      backgroundColor: CafeColors.bg,
      body: AnimatedBuilder(
        animation: _cart,
        builder: (context, _) {
          if (_cart.items.isEmpty) {
            return EmptyState(
              emoji: '🛒',
              title: 'Your cart is empty',
              subtitle: 'Add items from NutriCafe to get started',
              actionLabel: 'Browse Cafe',
              onAction: () => context.go('/home/food?segment=cafe'),
            );
          }
          return Column(
            children: [
              _cafeAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CafeDeliveryCard(
                        items: _cart.items,
                        onIncrement: (id) {
                          final item = _cart.items.lastWhere((i) => i.id == id);
                          _cart.add(item);
                        },
                        onDecrement: (id) => _cart.decrement(id),
                      ),
                      const SizedBox(height: 12),
                      CafeSustainabilityCard(
                        value: _skipCutlery,
                        onChanged: (v) => setState(() => _skipCutlery = v),
                      ),
                      const SizedBox(height: 16),
                      _upsellSection(),
                      const SizedBox(height: 12),
                      const CafeOffersCard(),
                      const SizedBox(height: 16),
                      CafeCheckoutBill(
                        itemsTotal: _subtotal,
                        originalTotal: _cafeOriginalTotal,
                        deliveryCharge: _cafeDelivery,
                        convenienceCharge: _cafeConvenience,
                        grandTotal: _total,
                        totalSavings: _cafeSavings,
                      ),
                      const SizedBox(height: 16),
                      const CafeDeliveryInstructions(),
                      const SizedBox(height: 16),
                      CafeTipCard(
                        selectedTip: _tip,
                        onTipSelected: (t) => setState(() => _tip = t),
                      ),
                      const SizedBox(height: 12),
                      CafeDonationRow(
                        added: _donationAdded,
                        onToggle: () =>
                            setState(() => _donationAdded = !_donationAdded),
                      ),
                      const SizedBox(height: 12),
                      const CafeCancellationPolicy(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              CafeCheckoutFooter(
                address: _displayAddress,
                total: _total,
                isLoading: _loading,
                onPlaceOrder: _pay,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _cafeAppBar() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: () => context.pop(),
            ),
            Expanded(
              child: Text(
                'Checkout',
                textAlign: TextAlign.center,
                style: AppTypography.h3,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: CafeColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: CafeColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.share, size: 16, color: CafeColors.accentGreen),
                  const SizedBox(width: 4),
                  Text(
                    'Share',
                    style: TextStyle(
                      color: CafeColors.accentGreen,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _upsellSection() {
    final upsell = MockData.cafeSections().bestsellers.take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('You might also like', style: AppTypography.h3),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 240,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: upsell.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) => CafeProductCard(
              dish: upsell[i],
              width: 160,
              compact: true,
              onAdd: () => _cart.add(CafeProductCard.toOrderItem(upsell[i])),
            ),
          ),
        ),
      ],
    );
  }

  Widget _legacyCheckoutScaffold() {
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.greenGlow : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? AppColors.green : AppColors.cardBorder,
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
