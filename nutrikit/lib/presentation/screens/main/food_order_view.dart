import 'package:flutter/material.dart';

import '../../../core/theme/app_typography.dart';
import '../../../core/theme/cafe_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/dish.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/mock_data.dart';
import '../../providers/cart_store.dart';
import '../../widgets/cafe/cafe_category_tile.dart';
import '../../widgets/cafe/cafe_filter_chips.dart';
import '../../widgets/cafe/cafe_floating_cart_bar.dart';
import '../../widgets/cafe/cafe_free_delivery_banner.dart';
import '../../widgets/cafe/cafe_hero_banner.dart';
import '../../widgets/cafe/cafe_menu_fab.dart';
import '../../widgets/cafe/cafe_product_card.dart';
import '../../widgets/cafe/cafe_section_header.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/error_state.dart';
import '../../widgets/common/shimmer_card.dart';

class FoodOrderView extends StatefulWidget {
  const FoodOrderView({super.key, this.isAddOnsContext = false});

  final bool isAddOnsContext;

  @override
  State<FoodOrderView> createState() => _FoodOrderViewState();
}

class _FoodOrderViewState extends State<FoodOrderView> {
  List<Dish> _dishes = [];
  CafeSections? _sections;
  bool _loading = true;
  String? _error;
  CafeFilter _filter = CafeFilter.none;
  String _categoryTab = 'All';
  bool _vegMode = false;

  static const _categoryTabs = [
    'All',
    'All-Day Breakfast',
    'Snacks',
    'Coffee',
    'Under ₹99',
    'Meals',
  ];

  static const _gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    mainAxisSpacing: 14,
    crossAxisSpacing: 14,
    childAspectRatio: 0.58,
  );

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = ApiService.instance;
      final dishes = await api
          .getKitchenMenu(addOnsOnly: widget.isAddOnsContext);
      CafeSections? sections;
      if (!AppConstants.useMock) {
        try {
          sections = await api.getCafeSections();
        } catch (_) {
          sections = null;
        }
      }
      if (!mounted) return;
      setState(() {
        _dishes = dishes;
        _sections = sections ?? MockData.cafeSections();
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

  List<Dish> get _filtered {
    var list = _dishes;
    if (_vegMode) {
      list = list.where((d) => d.isVeg).toList();
    }
    list = switch (_filter) {
      CafeFilter.veg => list.where((d) => d.isVeg).toList(),
      CafeFilter.nonVeg => list.where((d) => !d.isVeg).toList(),
      CafeFilter.highlyReordered =>
        list.where((d) => d.isHighlyReordered).toList(),
      CafeFilter.chefsChoice => list.where((d) => d.isChefsChoice).toList(),
      CafeFilter.none => list,
    };
    if (_categoryTab != 'All') {
      list = switch (_categoryTab) {
        'Snacks' => list.where((d) => d.category == 'Snack').toList(),
        'Coffee' => list.where((d) => d.category == 'Beverage').toList(),
        'Meals' => list.where((d) => d.category == 'Meals').toList(),
        'Under ₹99' => list.where((d) => d.price < 99).toList(),
        'All-Day Breakfast' =>
          list.where((d) => d.category == 'Breakfast').toList(),
        _ => list,
      };
    }
    return list;
  }

  void _onAdd(Dish dish) {
    CartStore.instance.add(CafeProductCard.toOrderItem(dish));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: CafeColors.accentGreen,
        duration: const Duration(milliseconds: 800),
        content: Text('${dish.name} added',
            style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomScrollView(
          controller: _scrollController,
          slivers: [
            const SliverToBoxAdapter(child: CafeHeroBanner()),
            if (_error != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ErrorState(message: _error!, onRetry: _load),
                ),
              )
            else if (_loading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: ShimmerList(count: 4, height: 180),
                ),
              )
            else ...[
              _orderAgainSliver(),
              _categoriesSliver(),
              SliverToBoxAdapter(child: _vegModeRow()),
              SliverToBoxAdapter(
                child: CafeFilterChips(
                  selected: _filter,
                  onSelected: (f) => setState(() => _filter = f),
                ),
              ),
              SliverToBoxAdapter(child: _categoryTabRow()),
              _sectionCarousel('BISTRO BESTSELLERS', _sections?.bestsellers),
              _sectionCarousel('LATE NIGHT CRAVINGS', _sections?.lateNight),
              if ((_sections?.partyPacks ?? []).isNotEmpty)
                _sectionCarousel('PARTY PACKS', _sections?.partyPacks),
              _gridSliver(),
            ],
            const SliverPadding(padding: EdgeInsets.only(bottom: 140)),
          ],
        ),
        const CafeFloatingCartBar(),
        CafeMenuFab(
          onTap: () => _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
          ),
        ),
        const CafeFreeDeliveryBanner(),
      ],
    );
  }

  Widget _vegModeRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'VEG MODE',
            style: AppTypography.label.copyWith(
              color: CafeColors.text,
              fontSize: 10,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 28,
            child: Switch(
              value: _vegMode,
              onChanged: (v) => setState(() => _vegMode = v),
              activeTrackColor: CafeColors.accentGreen,
              activeThumbColor: Colors.white,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryTabRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: _categoryTabs.map((tab) {
          final sel = tab == _categoryTab;
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => setState(() => _categoryTab = tab),
              child: Text(
                tab,
                style: TextStyle(
                  fontWeight: sel ? FontWeight.w900 : FontWeight.w600,
                  fontSize: 13,
                  color: sel ? CafeColors.text : CafeColors.muted,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _orderAgainSliver() {
    final items = _sections?.orderAgain ?? [];
    if (items.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CafeSectionHeader('Order Again'),
          SizedBox(
            height: 210,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, i) => CafeProductCard(
                dish: items[i],
                compact: true,
                width: 150,
                onAdd: () => _onAdd(items[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoriesSliver() {
    final cats = _sections?.categories ?? [];
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CafeSectionHeader("What's on your mind?"),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children:
                  cats.map((c) => CafeCategoryTile(category: c)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCarousel(String title, List<Dish>? items) {
    if (items == null || items.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CafeSectionHeader(title),
          SizedBox(
            height: 260,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, i) => CafeProductCard(
                dish: items[i],
                width: 170,
                onAdd: () => _onAdd(items[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gridSliver() {
    final dishes = _filtered;
    if (dishes.isEmpty) {
      return const SliverToBoxAdapter(
        child: EmptyState(
          emoji: '☕',
          title: 'Nothing here',
          subtitle: 'Try a different category or filter',
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      sliver: SliverGrid.builder(
        gridDelegate: _gridDelegate,
        itemCount: dishes.length,
        itemBuilder: (_, i) => CafeProductCard(
          dish: dishes[i],
          onAdd: () => _onAdd(dishes[i]),
        ),
      ),
    );
  }
}
