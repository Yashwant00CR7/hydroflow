import 'package:flutter/material.dart';
import '../chat_page.dart';
import '../products.dart';
import '../cart_page.dart';
import '../services/cart_service.dart';
import '../theme/app_colors.dart';

class AppBottomNavigation extends StatelessWidget {
  final String currentPage; // 'home' | 'chat' | 'products' | 'cart'
  final CartService cartService;

  const AppBottomNavigation({
    super.key,
    required this.currentPage,
    required this.cartService,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color:
            Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkNeutral100
                : const Color(0xFF1e3a8a),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavIcon(
            icon: Icons.home,
            isActive: currentPage == 'home',
            onTap: currentPage == 'home' ? null : () {},
          ),
          _NavIcon(
            icon: Icons.chat_bubble_outline,
            isActive: currentPage == 'chat',
            onTap:
                currentPage == 'chat'
                    ? null
                    : () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (c) => const ChatPage()),
                    ),
          ),
          _NavIcon(
            icon: Icons.inventory_2,
            isActive: currentPage == 'products',
            onTap:
                currentPage == 'products'
                    ? null
                    : () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (c) => const ProductsPage()),
                    ),
          ),
          _CartNavIcon(
            isActive: currentPage == 'cart',
            cartService: cartService,
            onTap:
                currentPage == 'cart'
                    ? null
                    : () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (c) => const CartPage()),
                    ),
          ),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback? onTap;
  const _NavIcon({required this.icon, required this.isActive, this.onTap});

  @override
  Widget build(BuildContext context) {
    final Widget child = Icon(
      icon,
      color:
          isActive
              ? Theme.of(context).colorScheme.secondary
              : Theme.of(context).brightness == Brightness.dark
              ? AppColors.techGreen
              : Colors.white,
      size: 20,
    );

    final Widget content =
        isActive
            ? Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkNeutral100
                        : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: child,
            )
            : child;

    if (onTap == null) return content;
    return GestureDetector(onTap: onTap, child: content);
  }
}

class _CartNavIcon extends StatelessWidget {
  final bool isActive;
  final CartService cartService;
  final VoidCallback? onTap;
  const _CartNavIcon({
    required this.isActive,
    required this.cartService,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final baseIcon = Stack(
      children: [
        Icon(
          Icons.shopping_cart,
          color:
              isActive
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(context).brightness == Brightness.dark
                  ? AppColors.techGreen
                  : Colors.white,
          size: 20,
        ),
        if (cartService.itemCount > 0)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? AppColors.error
                        : const Color(0xFFdc2626),
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                '${cartService.itemCount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );

    final Widget content =
        isActive
            ? Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkNeutral100
                        : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: baseIcon,
            )
            : baseIcon;

    if (onTap == null) return content;
    return GestureDetector(onTap: onTap, child: content);
  }
}
