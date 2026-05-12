import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus { pending, processing, shipped, delivered }

class OrderItem {
  final String productId;
  final String name;
  final double price;
  final int quantity;

  OrderItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }
}

class OrderModel {
  final String id;
  final String buyerId;
  final String sellerId;
  final List<OrderItem> items;
  final double total;
  final OrderStatus status;
  final DateTime createdAt;
  final String stripePaymentIntentId;

  OrderModel({
    required this.id,
    required this.buyerId,
    required this.sellerId,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.stripePaymentIntentId,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String documentId) {
    return OrderModel(
      id: documentId,
      buyerId: map['buyerId'] ?? '',
      sellerId: map['sellerId'] ?? '',
      items: (map['items'] as List<dynamic>? ?? [])
          .map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      total: (map['total'] ?? 0).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => OrderStatus.pending,
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      stripePaymentIntentId: map['stripePaymentIntentId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'buyerId': buyerId,
      'sellerId': sellerId,
      'items': items.map((item) => item.toMap()).toList(),
      'total': total,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'stripePaymentIntentId': stripePaymentIntentId,
    };
  }
}
