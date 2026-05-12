import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firestore_service.dart';
import '../services/config_service.dart';
import '../models/product_model.dart';
import '../models/promo_model.dart';
import 'auth_provider.dart';

final firestoreServiceProvider = Provider((ref) => FirestoreService());
final configServiceProvider = Provider((ref) => ConfigService());

final promoProvider = StreamProvider<PromoModel>((ref) {
  return ref.watch(configServiceProvider).getPromoBanner();
});

final productsStreamProvider = StreamProvider<List<ProductModel>>((ref) {
  return ref.watch(firestoreServiceProvider).getProducts();
});

final sellerProductsStreamProvider = StreamProvider<List<ProductModel>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return const Stream.empty();
  return ref.watch(firestoreServiceProvider).getSellerProducts(user.uid);
});

final productProvider = Provider((ref) => ProductNotifier(ref.watch(firestoreServiceProvider)));

class ProductNotifier {
  final FirestoreService _firestoreService;
  ProductNotifier(this._firestoreService);

  Future<void> addProduct(ProductModel product) async {
    await _firestoreService.addProduct(product);
  }

  Future<void> updateProduct(ProductModel product) async {
    await _firestoreService.updateProduct(product);
  }

  Future<void> deleteProduct(String productId) async {
    await _firestoreService.deleteProduct(productId);
  }
}
