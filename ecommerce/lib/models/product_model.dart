import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String sellerId;
  final String sellerName;
  final String name;
  final String description;
  final double price;
  final String category;
  final List<String> imageUrls;
  final int stock;
  final DateTime createdAt;
  final bool isActive;

  ProductModel({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrls,
    required this.stock,
    required this.createdAt,
    required this.isActive,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ProductModel(
      id: documentId,
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      category: map['category'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      stock: map['stock'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sellerId': sellerId,
      'sellerName': sellerName,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'imageUrls': imageUrls,
      'stock': stock,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
    };
  }
}
