import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/models.dart';
import '../../data/services/api_service.dart';
import '../../data/services/mock_data.dart';

/// Holds kitchens, the selected kitchen's menu + live order board, and drives
/// a simulated incoming-order feed in mock mode so the board feels live.
class KitchenStore extends ChangeNotifier {
  KitchenStore({ApiService? api}) : _api = api ?? ApiService.instance;

  final ApiService _api;

  List<Kitchen> _kitchens = [];
  Kitchen? _selected;
  List<MenuItem> _menu = [];
  final List<FoodOrder> _orders = [];

  bool _loadingKitchens = false;
  bool _loadingBoard = false;
  String? _error;

  Timer? _feedTimer;
  int _feedSeq = 0;

  List<Kitchen> get kitchens => List.unmodifiable(_kitchens);
  Kitchen? get selected => _selected;
  List<MenuItem> get menu => List.unmodifiable(_menu);
  bool get loadingKitchens => _loadingKitchens;
  bool get loadingBoard => _loadingBoard;
  String? get error => _error;

  List<FoodOrder> ordersByStatus(OrderStatus status) =>
      _orders.where((o) => o.status == status).toList();

  List<FoodOrder> get activeOrders =>
      _orders.where((o) => o.status.isActive).toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  int get newCount => ordersByStatus(OrderStatus.newOrder).length;

  // ----------------------------------------------------------- Kitchens
  Future<void> loadKitchens({String? orgId}) async {
    _loadingKitchens = true;
    notifyListeners();
    try {
      _kitchens = await _api.listKitchens(orgId: orgId);
      _error = null;
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _loadingKitchens = false;
      notifyListeners();
    }
  }

  Future<Kitchen?> addKitchen({
    required String name,
    String? address,
    String? city,
  }) async {
    try {
      final created =
          await _api.createKitchen(name: name, address: address, city: city);
      _kitchens = [created, ..._kitchens];
      _error = null;
      notifyListeners();
      return created;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return null;
    }
  }

  // ----------------------------------------------- Selected kitchen board
  Future<void> selectKitchen(Kitchen kitchen) async {
    _selected = kitchen;
    notifyListeners();
    await refreshBoard();
    _startFeed();
  }

  Future<void> ensureSelected() async {
    if (_selected != null) return;
    if (_kitchens.isEmpty) {
      await loadKitchens();
    }
    if (_kitchens.isNotEmpty) {
      await selectKitchen(_kitchens.first);
    }
  }

  Future<void> refreshBoard() async {
    final kitchen = _selected;
    if (kitchen == null) return;
    _loadingBoard = true;
    notifyListeners();
    try {
      _menu = await _api.getMenu(kitchen.id);
      final orders = await _api.getOrders(kitchen.id);
      _orders
        ..clear()
        ..addAll(orders);
      _error = null;
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _loadingBoard = false;
      notifyListeners();
    }
  }

  Future<void> advanceOrder(FoodOrder order) async {
    final next = order.status.next;
    if (next == null) return;
    await _setStatus(order, next);
  }

  Future<void> cancelOrder(FoodOrder order) async {
    await _setStatus(order, OrderStatus.cancelled);
  }

  Future<void> _setStatus(FoodOrder order, OrderStatus status) async {
    final prev = order.status;
    order.status = status; // optimistic
    notifyListeners();
    try {
      await _api.updateOrderStatus(order, status);
    } on ApiException catch (e) {
      order.status = prev;
      _error = e.message;
      notifyListeners();
    }
  }

  // --------------------------------------------------------------- Menu
  Future<void> addMenuItem({
    required String name,
    String? description,
    required MealCategory category,
    required int priceCents,
    required bool veg,
  }) async {
    final kitchen = _selected;
    if (kitchen == null) return;
    try {
      final item = await _api.createMenuItem(
        kitchen.id,
        name: name,
        description: description,
        category: category,
        priceCents: priceCents,
        veg: veg,
      );
      _menu = [..._menu, item];
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
    }
  }

  Future<void> toggleAvailability(MenuItem item) async {
    try {
      final updated =
          await _api.updateMenuItem(item, available: !item.available);
      _menu = _menu.map((m) => m.id == item.id ? updated : m).toList();
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
    }
  }

  // -------------------------------------------------- Live feed (mock only)
  void _startFeed() {
    _feedTimer?.cancel();
    if (!AppConstants.useMock) return;
    _feedTimer = Timer.periodic(const Duration(seconds: 12), (_) {
      final kitchen = _selected;
      if (kitchen == null) return;
      _orders.insert(0, MockData.incomingOrder(kitchen.id, _feedSeq++));
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _feedTimer?.cancel();
    super.dispose();
  }
}
