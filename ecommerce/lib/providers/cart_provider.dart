import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';

class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  OrderItem toOrderItem() {
    return OrderItem(
      productId: product.id,
      name: product.name,
      price: product.price,
      quantity: quantity,
    );
  }
}

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addToCart(ProductModel product) {
    final existingIndex = state.indexWhere((item) => item.product.id == product.id);
    if (existingIndex != -1) {
      state[existingIndex].quantity++;
      state = [...state];
    } else {
      state = [...state, CartItem(product: product)];
    }
  }

  void removeFromCart(String productId) {
    state = state.where((item) => item.product.id != productId).toList();
  }

  void updateQuantity(String productId, int quantity) {
    final index = state.indexWhere((item) => item.product.id == productId);
    if (index != -1) {
      if (quantity <= 0) {
        removeFromCart(productId);
      } else {
        state[index].quantity = quantity;
        state = [...state];
      }
    }
  }

  void clearCart() {
    state = [];
  }

  double get total {
    return state.fold(0, (sum, item) => sum + (item.product.price * item.quantity));
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});
