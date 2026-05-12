import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../screens/home/home_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/product/product_detail_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/checkout/checkout_screen.dart';
import '../screens/orders/order_history_screen.dart';
import '../models/product_model.dart';
import '../providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    // Temporary: Disable all redirects to fix navigation bugs
    redirect: (context, state) => null,
    routes: [
      GoRoute(path: '/', name: 'home', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/login', name: 'login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/signup', name: 'signup', builder: (context, state) => const SignupScreen()),
      GoRoute(
        path: '/product/:id',
        name: 'product_detail',
        builder: (context, state) => ProductDetailScreen(product: state.extra as ProductModel),
      ),
      GoRoute(path: '/cart', name: 'cart', builder: (context, state) => const CartScreen()),
      GoRoute(path: '/checkout', name: 'checkout', builder: (context, state) => const CheckoutScreen()),
      GoRoute(path: '/orders', name: 'orders', builder: (context, state) => const OrderHistoryScreen()),
    ],
  );
});
