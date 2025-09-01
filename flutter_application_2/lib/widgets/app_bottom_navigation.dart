import 'package:flutter/material.dart';
import 'dart:ui';
import '../chat_page.dart';
import '../products.dart';
import '../cart_page.dart';
import '../services/cart_service.dart';

class AppBottomNavigation extends StatelessWidget {
  final String currentPage;
  final CartService? cartService;

  const AppBottomNavigation({
    super.key,
    required this.currentPage,
    this.cartService,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 204),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 26),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context,
                  icon: Icons.home,
                  label: 'Home',
                  isActive: currentPage == 'home',
                  onTap: () {
                    if (currentPage != 'home') {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  },
                ),
                _buildNavItem(
                  context,
                  icon: Icons.chat_bubble_outline,
                  label: 'Chat',
                  isActive: currentPage == 'chat',
                  onTap: () {
                    if (currentPage != 'chat') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ChatPage()),
                      );
                    }
                  },
                ),
                _buildNavItem(
                  context,
                  icon: Icons.inventory_2,
                  label: 'Products',
                  isActive: currentPage == 'products',
                  onTap: () {
                    if (currentPage != 'products') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProductsPage()),
                      );
                    }
                  },
                ),
                _buildNavItem(
                  context,
                  icon: Icons.shopping_cart,
                  label: 'Cart',
                  isActive: currentPage == 'cart',
                  showBadge: cartService != null && cartService!.itemCount > 0,
                  badgeCount: cartService?.itemCount ?? 0,
                  onTap: () {
                    if (currentPage != 'cart') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CartPage()),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    bool showBadge = false,
    int badgeCount = 0,
  }) {
    final color = isActive
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 153);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        decoration: BoxDecoration(
          color: isActive ? Theme.of(context).colorScheme.primary.withValues(alpha: 26) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: color, size: 24),
                if (showBadge && badgeCount > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$badgeCount',
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
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
