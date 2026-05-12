import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/product_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/product_model.dart';
import '../../models/order_model.dart';
import '../../core/constants.dart';

class SellerDashboardScreen extends ConsumerWidget {
  const SellerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Seller Dashboard'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'My Products'),
              Tab(text: 'Incoming Orders'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _SellerProductList(),
            _IncomingOrdersList(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/seller/add-product'),
          label: const Text('Add Product'),
          icon: const Icon(Icons.add),
          backgroundColor: AppColors.primary,
        ),
      ),
    );
  }
}

class _SellerProductList extends ConsumerWidget {
  const _SellerProductList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(sellerProductsStreamProvider);

    return productsAsync.when(
      data: (products) => products.isEmpty
          ? const Center(child: Text('No products added yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: product.imageUrls.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(product.imageUrls[0], fit: BoxFit.cover),
                          )
                        : const Icon(Icons.image, color: Colors.grey),
                  ),
                  title: Text(product.name),
                  subtitle: Text('\$${product.price.toStringAsFixed(2)} • Stock: ${product.stock}'),
                  trailing: Switch(
                    value: product.isActive,
                    onChanged: (val) {
                      final updated = ProductModel(
                        id: product.id,
                        sellerId: product.sellerId,
                        sellerName: product.sellerName,
                        name: product.name,
                        description: product.description,
                        price: product.price,
                        category: product.category,
                        imageUrls: product.imageUrls,
                        stock: product.stock,
                        createdAt: product.createdAt,
                        isActive: val,
                      );
                      ref.read(productProvider).updateProduct(updated);
                    },
                  ),
                );
              },
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, st) => Center(child: Text('Error: $err')),
    );
  }
}

class _IncomingOrdersList extends ConsumerWidget {
  const _IncomingOrdersList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(sellerOrdersStreamProvider);

    return ordersAsync.when(
      data: (orders) => orders.isEmpty
          ? const Center(child: Text('No orders yet.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = orders[index];
                return _OrderManagementCard(order: order);
              },
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, st) => Center(child: Text('Error: $err')),
    );
  }
}

class _OrderManagementCard extends ConsumerWidget {
  final OrderModel order;
  const _OrderManagementCard({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Order #${order.id.substring(0, 8).toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold)),
                DropdownButton<OrderStatus>(
                  value: order.status,
                  onChanged: (status) {
                    if (status != null) {
                      ref.read(orderProvider).updateOrderStatus(order.id, status);
                    }
                  },
                  items: OrderStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status.name.toUpperCase(), style: const TextStyle(fontSize: 12)),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...order.items.map((item) => Text('${item.quantity}x ${item.name}', style: const TextStyle(fontSize: 14))),
            const Divider(),
            Text('Total Earnings: \$${order.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          ],
        ),
      ),
    );
  }
}
