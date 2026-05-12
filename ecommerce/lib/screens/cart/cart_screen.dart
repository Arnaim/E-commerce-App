import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/cart_provider.dart';
import '../../core/constants.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('My Bag')),
      body: cartItems.isEmpty
          ? _buildEmptyCart(context)
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(24),
                    itemCount: cartItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 24),
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return _buildCartItem(context, cartNotifier, item);
                    },
                  ),
                ),
                _buildSummary(context, cartNotifier.total),
              ],
            ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('Your bag is empty', style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () => context.go('/'),
            child: const Text('Start Shopping'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartNotifier notifier, CartItem item) {
    return Row(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: item.product.imageUrls.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(item.product.imageUrls[0], fit: BoxFit.cover),
                )
              : const Icon(Icons.face_retouching_natural, color: Color(0xFFF06292)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.product.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text('\$${item.product.price.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.primary)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildSmallQuantitySelector(notifier, item),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    onPressed: () => notifier.removeFromCart(item.product.id),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSmallQuantitySelector(CartNotifier notifier, CartItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 16),
            onPressed: () => notifier.updateQuantity(item.product.id, item.quantity - 1),
          ),
          Text(item.quantity.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
          IconButton(
            icon: const Icon(Icons.add, size: 16),
            onPressed: () => notifier.updateQuantity(item.product.id, item.quantity + 1),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(BuildContext context, double total) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -5),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(fontSize: 18, color: Colors.grey)),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => context.push('/checkout'),
            child: const Text('Proceed to Checkout'),
          ),
        ],
      ),
    );
  }
}
