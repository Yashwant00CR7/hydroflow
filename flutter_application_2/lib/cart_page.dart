import 'package:flutter/material.dart';
import 'services/cart_service.dart';

import 'widgets/glass_container.dart';
import 'theme/app_colors.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartService _cartService = CartService();

  @override
  void initState() {
    super.initState();
    _cartService.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    _cartService.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _cartService.items.isEmpty
          ? _buildEmptyCart()
          : _buildCartItems(),
      bottomNavigationBar: _buildBottomSection(),
    );
  }

  Widget _buildEmptyCart() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text('Your cart is empty', style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildCartItems() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _cartService.items.length,
      itemBuilder: (context, index) {
        final item = _cartService.items[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item.image,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(item.price, style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary
                      )),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        _cartService.updateQuantity(item.id, item.quantity - 1);
                      },
                    ),
                    Text(item.quantity.toString(), style: Theme.of(context).textTheme.titleMedium),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () {
                        _cartService.updateQuantity(item.id, item.quantity + 1);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.error),
                      onPressed: () {
                        _cartService.removeItem(item.id);
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomSection() {
    if (_cartService.items.isEmpty) return const SizedBox.shrink();

    return GlassContainer(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      borderRadius: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total', style: Theme.of(context).textTheme.labelMedium),
              Text(
                '₹${_cartService.totalAmount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.payment),
            label: const Text('Checkout'),
          ),
        ],
      ),
    );
  }
}
