enum CartItemType { planSlot, addOn }

class OrderItem {
  const OrderItem({
    required this.id,
    required this.name,
    required this.emoji,
    required this.portion,
    required this.calories,
    required this.price,
    this.type = CartItemType.addOn,
  });

  final String id;
  final String name;
  final String emoji;
  final String portion;
  final int calories;
  final double price;
  final CartItemType type;

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        id: json['id']?.toString() ?? '',
        name: json['name'] as String? ?? '',
        emoji: json['emoji'] as String? ?? '🍽️',
        portion: json['portion'] as String? ?? '',
        calories: (json['calories'] as num?)?.toInt() ?? 0,
        price: (json['price'] as num?)?.toDouble() ?? 0,
        type: json['type'] == 'planSlot'
            ? CartItemType.planSlot
            : CartItemType.addOn,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'portion': portion,
        'calories': calories,
        'price': price,
        'type': type.name,
      };
}

class OrderRequest {
  const OrderRequest({
    required this.itemIds,
    required this.slot,
    required this.address,
    required this.total,
  });

  final List<String> itemIds;
  final String slot;
  final String address;
  final double total;

  Map<String, dynamic> toJson() => {
        'itemIds': itemIds,
        'slot': slot,
        'address': address,
        'total': total,
      };
}

class Order {
  const Order({
    required this.id,
    required this.total,
    required this.eta,
    required this.status,
  });

  final String id;
  final double total;
  final String eta;
  final String status;

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'] as String? ?? '',
        total: (json['total'] as num?)?.toDouble() ?? 0,
        eta: json['eta'] as String? ?? '',
        status: json['status'] as String? ?? '',
      );
}

class TrackingStep {
  const TrackingStep({
    required this.label,
    required this.time,
    required this.state,
  });

  final String label;
  final String time;
  final String state;

  factory TrackingStep.fromJson(Map<String, dynamic> json) => TrackingStep(
        label: json['label'] as String? ?? '',
        time: json['time'] as String? ?? '',
        state: json['state'] as String? ?? 'pending',
      );
}

class OrderStatus {
  const OrderStatus({
    required this.orderId,
    required this.etaMinutes,
    required this.steps,
  });

  final String orderId;
  final int etaMinutes;
  final List<TrackingStep> steps;

  factory OrderStatus.fromJson(Map<String, dynamic> json) => OrderStatus(
        orderId: json['orderId'] as String? ?? '',
        etaMinutes: (json['etaMinutes'] as num?)?.toInt() ?? 0,
        steps: (json['steps'] as List<dynamic>? ?? [])
            .map((e) => TrackingStep.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
