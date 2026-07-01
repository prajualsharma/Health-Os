import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

enum SessionRole { corporate, kitchen }

enum MealCategory { breakfast, lunch, dinner, snack, beverage }

extension MealCategoryX on MealCategory {
  String get api => name.toUpperCase();
  String get label => switch (this) {
        MealCategory.breakfast => 'Breakfast',
        MealCategory.lunch => 'Lunch',
        MealCategory.dinner => 'Dinner',
        MealCategory.snack => 'Snacks',
        MealCategory.beverage => 'Beverages',
      };
  String get emoji => switch (this) {
        MealCategory.breakfast => '\u{1F373}', // fried egg
        MealCategory.lunch => '\u{1F35B}', // curry
        MealCategory.dinner => '\u{1F37D}', // plate
        MealCategory.snack => '\u{1F37F}', // popcorn
        MealCategory.beverage => '\u{2615}', // coffee
      };

  static MealCategory parse(String? v) {
    switch ((v ?? '').toUpperCase()) {
      case 'BREAKFAST':
        return MealCategory.breakfast;
      case 'LUNCH':
        return MealCategory.lunch;
      case 'DINNER':
        return MealCategory.dinner;
      case 'SNACK':
        return MealCategory.snack;
      case 'BEVERAGE':
        return MealCategory.beverage;
      default:
        return MealCategory.lunch;
    }
  }
}

enum OrderStatus { newOrder, accepted, preparing, ready, pickedUp, cancelled }

extension OrderStatusX on OrderStatus {
  String get api => switch (this) {
        OrderStatus.newOrder => 'NEW',
        OrderStatus.accepted => 'ACCEPTED',
        OrderStatus.preparing => 'PREPARING',
        OrderStatus.ready => 'READY',
        OrderStatus.pickedUp => 'PICKED_UP',
        OrderStatus.cancelled => 'CANCELLED',
      };

  String get label => switch (this) {
        OrderStatus.newOrder => 'New',
        OrderStatus.accepted => 'Accepted',
        OrderStatus.preparing => 'Preparing',
        OrderStatus.ready => 'Ready',
        OrderStatus.pickedUp => 'Picked up',
        OrderStatus.cancelled => 'Cancelled',
      };

  Color get color => switch (this) {
        OrderStatus.newOrder => AppColors.statusNew,
        OrderStatus.accepted => AppColors.statusAccepted,
        OrderStatus.preparing => AppColors.statusPreparing,
        OrderStatus.ready => AppColors.statusReady,
        OrderStatus.pickedUp => AppColors.statusPicked,
        OrderStatus.cancelled => AppColors.statusCancelled,
      };

  /// The next status when the kitchen advances the order, if any.
  OrderStatus? get next => switch (this) {
        OrderStatus.newOrder => OrderStatus.accepted,
        OrderStatus.accepted => OrderStatus.preparing,
        OrderStatus.preparing => OrderStatus.ready,
        OrderStatus.ready => OrderStatus.pickedUp,
        OrderStatus.pickedUp => null,
        OrderStatus.cancelled => null,
      };

  /// CTA label for advancing the order.
  String? get advanceLabel => switch (this) {
        OrderStatus.newOrder => 'Accept',
        OrderStatus.accepted => 'Start preparing',
        OrderStatus.preparing => 'Mark ready',
        OrderStatus.ready => 'Mark picked up',
        _ => null,
      };

  bool get isActive =>
      this == OrderStatus.newOrder ||
      this == OrderStatus.accepted ||
      this == OrderStatus.preparing ||
      this == OrderStatus.ready;

  static OrderStatus parse(String? v) {
    switch ((v ?? '').toUpperCase()) {
      case 'NEW':
        return OrderStatus.newOrder;
      case 'ACCEPTED':
        return OrderStatus.accepted;
      case 'PREPARING':
        return OrderStatus.preparing;
      case 'READY':
        return OrderStatus.ready;
      case 'PICKED_UP':
        return OrderStatus.pickedUp;
      case 'CANCELLED':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.newOrder;
    }
  }
}

class Kitchen {
  Kitchen({
    required this.id,
    required this.orgId,
    required this.name,
    this.address,
    this.city,
    this.status = 'ACTIVE',
  });

  final String id;
  final String orgId;
  final String name;
  final String? address;
  final String? city;
  final String status;

  factory Kitchen.fromJson(Map<String, dynamic> json) => Kitchen(
        id: json['id'] as String,
        orgId: json['orgId'] as String? ?? '',
        name: json['name'] as String? ?? '',
        address: json['address'] as String?,
        city: json['city'] as String?,
        status: json['status'] as String? ?? 'ACTIVE',
      );
}

class MenuItem {
  MenuItem({
    required this.id,
    required this.kitchenId,
    required this.name,
    this.description,
    required this.category,
    required this.priceCents,
    this.veg = true,
    this.available = true,
  });

  final String id;
  final String kitchenId;
  final String name;
  final String? description;
  final MealCategory category;
  final int priceCents;
  final bool veg;
  final bool available;

  double get price => priceCents / 100.0;

  MenuItem copyWith({int? priceCents, bool? available, MealCategory? category}) =>
      MenuItem(
        id: id,
        kitchenId: kitchenId,
        name: name,
        description: description,
        category: category ?? this.category,
        priceCents: priceCents ?? this.priceCents,
        veg: veg,
        available: available ?? this.available,
      );

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
        id: json['id'] as String,
        kitchenId: json['kitchenId'] as String? ?? '',
        name: json['name'] as String? ?? '',
        description: json['description'] as String?,
        category: MealCategoryX.parse(json['category'] as String?),
        priceCents: (json['priceCents'] as num?)?.toInt() ?? 0,
        veg: json['veg'] as bool? ?? true,
        available: json['available'] as bool? ?? true,
      );

  factory MenuItem.fromCatalogJson(Map<String, dynamic> json) => MenuItem(
        id: json['id'] as String,
        kitchenId: json['kitchenId'] as String? ?? '',
        name: json['name'] as String? ?? '',
        description: json['description'] as String?,
        category: MealCategoryX.parse(json['mealCategory'] as String?),
        priceCents: (json['priceCents'] as num?)?.toInt() ?? 0,
        veg: json['veg'] as bool? ?? true,
        available: json['available'] as bool? ?? true,
      );
}

class OrderLine {
  OrderLine({
    required this.name,
    required this.quantity,
    required this.priceCents,
    this.menuItemId,
  });

  final String? menuItemId;
  final String name;
  final int quantity;
  final int priceCents;

  factory OrderLine.fromJson(Map<String, dynamic> json) => OrderLine(
        menuItemId: json['menuItemId'] as String?,
        name: json['name'] as String? ?? '',
        quantity: (json['quantity'] as num?)?.toInt() ?? 1,
        priceCents: (json['priceCents'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        if (menuItemId != null) 'menuItemId': menuItemId,
        'name': name,
        'quantity': quantity,
        'priceCents': priceCents,
      };
}

class FoodOrder {
  FoodOrder({
    required this.id,
    required this.kitchenId,
    required this.orderCode,
    required this.customerName,
    this.customerPhone,
    required this.status,
    required this.totalCents,
    required this.items,
    required this.createdAt,
  });

  final String id;
  final String kitchenId;
  final String orderCode;
  final String customerName;
  final String? customerPhone;
  OrderStatus status;
  final int totalCents;
  final List<OrderLine> items;
  final DateTime createdAt;

  double get total => totalCents / 100.0;
  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);

  factory FoodOrder.fromJson(Map<String, dynamic> json) => FoodOrder(
        id: json['id'] as String,
        kitchenId: json['kitchenId'] as String? ?? '',
        orderCode: json['orderCode'] as String? ?? '',
        customerName: json['customerName'] as String? ?? '',
        customerPhone: json['customerPhone'] as String?,
        status: OrderStatusX.parse(json['status'] as String?),
        totalCents: (json['totalCents'] as num?)?.toInt() ?? 0,
        items: ((json['items'] as List<dynamic>?) ?? [])
            .map((e) => OrderLine.fromJson(e as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );
}
