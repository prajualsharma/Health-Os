import 'package:flutter/foundation.dart';

import '../../data/models/order.dart';

/// Simple in-memory cart shared across Kitchen, MealDetail and Cart screens.
class CartStore extends ChangeNotifier {
  CartStore._();
  static final CartStore instance = CartStore._();

  final List<OrderItem> _items = [];
  bool _seeded = false;

  List<OrderItem> get items => List.unmodifiable(_items);

  double get subtotal => _items.fold(0, (sum, i) => sum + i.price);

  int quantityFor(String id) => _items.where((i) => i.id == id).length;

  void add(OrderItem item) {
    _items.add(item);
    notifyListeners();
  }

  void increment(OrderItem item) => add(item);

  void decrement(String id) {
    final idx = _items.indexWhere((i) => i.id == id);
    if (idx >= 0) {
      _items.removeAt(idx);
      notifyListeners();
    }
  }

  void remove(String id) {
    _items.removeWhere((i) => i.id == id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  /// Seeds the cart once with sample items so the cart screen is non-empty in
  /// the demo flow.
  void seedIfEmpty(List<OrderItem> defaults) {
    if (_seeded || _items.isNotEmpty) return;
    _items.addAll(defaults);
    _seeded = true;
  }
}
