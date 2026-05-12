import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/user_model.dart';
import '../../models/promo_model.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsStreamProvider);
    final userAsync = ref.watch(userModelProvider);
    final promoAsync = ref.watch(promoProvider);
    final cartItems = ref.watch(cartProvider);

    return Scaffold(
      drawer: _buildDrawer(context, ref, userAsync),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: const Text('Glow & Co.'),
            actions: [
              IconButton(
                icon: Badge(
                  label: Text(cartItems.length.toString()),
                  isLabelVisible: cartItems.isNotEmpty,
                  child: const Icon(Icons.shopping_bag_outlined),
                ),
                onPressed: () => context.push('/cart'),
              ),
            ],
          ),
          productsAsync.when(
            data: (products) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchBar(),
                    const SizedBox(height: 24),
                    promoAsync.when(
                      data: (promo) => _buildPromoBanner(promo),
                      loading: () => const SizedBox(height: 180, child: Center(child: CircularProgressIndicator())),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 32),
                    _buildSectionHeader('Categories', () {}),
                    const SizedBox(height: 16),
                    _buildCategoryList(products),
                    const SizedBox(height: 32),
                    _buildSectionHeader('Latest Arrivals', () {}),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
            error: (err, stack) => SliverToBoxAdapter(child: Center(child: Text('Error: $err'))),
          ),
          productsAsync.when(
            data: (products) => SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = products[index];
                    return _buildProductCard(context, ref, product);
                  },
                  childCount: products.length,
                ),
              ),
            ),
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: Center(child: Text('Error: $err')),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, WidgetRef ref, AsyncValue<UserModel?> userAsync) {
    final authState = ref.watch(authStateProvider);

    return Drawer(
      child: Column(
        children: [
          // Header Section
          userAsync.when(
            data: (user) => UserAccountsDrawerHeader(
              accountName: Text(user?.displayName ?? 'Guest User'),
              accountEmail: Text(user?.email ?? (authState.value != null ? 'Syncing Profile...' : 'Not signed in')),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  user != null && user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 24, color: AppColors.primary),
                ),
              ),
              decoration: const BoxDecoration(color: AppColors.primary),
            ),
            loading: () => const UserAccountsDrawerHeader(
              accountName: Text('Loading...'),
              accountEmail: Text(''),
              currentAccountPicture: CircleAvatar(child: CircularProgressIndicator(color: Colors.white)),
              decoration: BoxDecoration(color: AppColors.primary),
            ),
            error: (err, st) => UserAccountsDrawerHeader(
              accountName: const Text('Account Error'),
              accountEmail: const Text('Tap logout to reset'),
              currentAccountPicture: const CircleAvatar(child: Icon(Icons.error, color: Colors.white)),
              decoration: const BoxDecoration(color: AppColors.primary),
            ),
          ),
          
          // Menu Section
          Expanded(
            child: authState.when(
              data: (firebaseUser) {
                if (firebaseUser == null) {
                  // User is definitely NOT logged in
                  return ListView(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.login),
                        title: const Text('Login'),
                        onTap: () {
                          Navigator.pop(context);
                          GoRouter.of(context).go('/login');
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.person_add),
                        title: const Text('Create Account'),
                        onTap: () {
                          Navigator.pop(context);
                          GoRouter.of(context).go('/signup');
                        },
                      ),
                    ],
                  );
                } else {
                  // User IS logged in
                  return Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.shopping_bag_outlined),
                        title: const Text('My Cart'),
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/cart');
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.history),
                        title: const Text('My Orders'),
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/orders');
                        },
                      ),
                      const Spacer(),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.red),
                        title: const Text('Logout', style: TextStyle(color: Colors.red)),
                        onTap: () {
                          ref.read(authNotifierProvider.notifier).logout();
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) => ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('Retry Login'),
                onTap: () => ref.read(authNotifierProvider.notifier).logout(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search for lipstick, cream...',
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildPromoBanner(PromoModel promo) {
    Color parseColor(String hex) {
      try {
        final buffer = StringBuffer();
        if (hex.length == 6 || hex.length == 7) buffer.write('ff');
        buffer.write(hex.replaceFirst('#', '').replaceFirst('0x', ''));
        return Color(int.parse(buffer.toString(), radix: 16));
      } catch (_) {
        return AppColors.primary; // Fallback color
      }
    }

    List<Color> colors;
    if (promo.gradientHexColors.isEmpty) {
      colors = [AppColors.primary, AppColors.secondary];
    } else {
      colors = promo.gradientHexColors.map(parseColor).toList();
    }

    // Final safety check for gradient
    if (colors.isEmpty) colors = [AppColors.primary, AppColors.secondary];
    if (colors.length == 1) colors.add(colors.first.withOpacity(0.8));

    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.auto_awesome,
              size: 150,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  promo.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF880E4F),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  promo.subtitle,
                  style: const TextStyle(fontSize: 16, color: Color(0xFFAD1457)),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF880E4F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(promo.buttonText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: const Text('See All'),
        ),
      ],
    );
  }

  Widget _buildCategoryList(List<dynamic> products) {
    final categories = {'All', ...products.map((p) => p.category as String).toSet()};
    final categoryList = categories.toList();

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categoryList.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final isSelected = index == 0; // Simplified for this example
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: isSelected
                  ? null
                  : Border.all(color: Colors.grey.shade200),
            ),
            child: Center(
              child: Text(
                categoryList[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, WidgetRef ref, dynamic product) {
    return InkWell(
      onTap: () => context.push('/product/${product.id}', extra: product),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: product.imageUrls.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        child: Image.network(product.imageUrls[0], fit: BoxFit.cover),
                      )
                    : const Center(
                        child: Icon(Icons.face_retouching_natural, size: 40, color: Color(0xFFF06292)),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.sellerName,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.primary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_shopping_cart, color: AppColors.primary, size: 20),
                        onPressed: () {
                          ref.read(cartProvider.notifier).addToCart(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${product.name} added to cart')),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
