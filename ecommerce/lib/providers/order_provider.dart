import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firestore_service.dart';
import '../models/order_model.dart';
import 'auth_provider.dart';
import 'product_provider.dart';

final buyerOrdersStreamProvider = StreamProvider<List<OrderModel>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return const Stream.empty();
  return ref.watch(firestoreServiceProvider).getBuyerOrders(user.uid);
});

final sellerOrdersStreamProvider = StreamProvider<List<OrderModel>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return const Stream.empty();
  return ref.watch(firestoreServiceProvider).getSellerOrders(user.uid);
});

final orderProvider = Provider((ref) => OrderNotifier(ref.watch(firestoreServiceProvider)));

class OrderNotifier {
  final FirestoreService _firestoreService;
  OrderNotifier(this._firestoreService);

  Future<void> createOrder(OrderModel order) async {
    await _firestoreService.createOrder(order);
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _firestoreService.updateOrderStatus(orderId, status);
  }
}
