import 'package:flutter/material.dart';
import 'cart_page.dart';
import 'services/cart_service.dart';

import 'widgets/glass_container.dart';
import 'theme/app_colors.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final CartService _cartService = CartService();

  final List<Map<String, dynamic>> products = [
    {
      "name": "Hydraulic Pump",
      "category": "Pumps",
      "price": "₹1,25,000",
      "image": "https://shorturl.at/Ovp6D",
      "description":
          "High-performance hydraulic pump for industrial applications",
      "rating": 4.8,
      "inStock": true,
    },
    {
      "name": "Air Filter",
      "category": "Filters",
      "price": "₹8,500",
      "image": "https://shorturl.at/sTrJw",
      "description": "Premium air filtration system for clean operation",
      "rating": 4.6,
      "inStock": true,
    },
    {
      "name": "Hose Pipe",
      "category": "Connections",
      "price": "₹4,500",
      "image":
          "https://5.imimg.com/data5/ANDROID/Default/2023/8/338177897/JS/BV/JX/1895445/product-jpeg-500x500.jpg",
      "description": "Durable hydraulic hose for high-pressure systems",
      "rating": 4.7,
      "inStock": true,
    },
    {
      "name": "Gear Coupling",
      "category": "Couplings",
      "price": "₹32,000",
      "image":
          "https://5.imimg.com/data5/NSDMERP/Default/2023/3/OQ/UQ/HK/1895445/flexible-drive-gear-coupling-1678173692042-500x500.jpg",
      "description": "Flexible gear coupling for smooth power transmission",
      "rating": 4.9,
      "inStock": false,
    },
    {
      "name": "Connectors",
      "category": "Connectors",
      "price": "₹18,000",
      "image":
          "https://sealexcel.com/wp-content/uploads/2020/02/37-Flare-Tube-Fittings.jpg",
      "description":
          "High-quality stainless steel connectors for hydraulic systems",
      "rating": 4.8,
      "inStock": true,
    },
    {
      "name": "Washer",
      "category": "Seals",
      "price": "₹2,500",
      "image":
          "https://5.imimg.com/data5/ANDROID/Default/2024/9/454473881/JJ/NR/EI/15495695/product-jpeg-250x250.jpg",
      "description": "Premium bonded seal washer for reliable sealing",
      "rating": 4.7,
      "inStock": true,
    },
  ];

  String selectedCategory = "All";
  final List<String> categories = [
    "All",
    "Pumps",
    "Filters",
    "Connections",
    "Couplings",
    "Connectors",
    "Seals",
  ];

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

  void _addToCart(Map<String, dynamic> product) {
    if (!product["inStock"]) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This item is out of stock'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final cartItem = CartItem(
      id: product["name"], // Using name as ID for simplicity
      name: product["name"],
      image: product["image"],
      price: product["price"],
      category: product["category"],
      description: product["description"],
      rating: product["rating"].toDouble(),
    );

    _cartService.addItem(cartItem);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product["name"]} added to cart'),
        backgroundColor: AppColors.success,
        action: SnackBarAction(
          label: 'View Cart',
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartPage()),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts =
        selectedCategory == "All"
            ? products
            : products
                .where((product) => product["category"] == selectedCategory)
                .toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            title: Text('Products'),
            floating: true,
            pinned: true,
            snap: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = category == selectedCategory;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: isSelected
                            ? null
                            : Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 26),
                              ),
                      ),
                      child: Center(
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(12),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final product = filteredProducts[index];
                  return GlassContainer(
                    borderRadius: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(
                                  product["image"],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.image_not_supported),
                                ),
                                if (!product["inStock"])
                                  Container(
                                    color: Colors.black.withValues(alpha: 128),
                                    child: const Center(
                                      child: Text(
                                        'Out of Stock',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product["category"],
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  product["name"],
                                  style: Theme.of(context).textTheme.titleMedium,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Spacer(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      product["price"],
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => _addToCart(product),
                                      icon: Icon(
                                        _cartService.isInCart(product["name"])
                                            ? Icons.check_circle
                                            : Icons.add_circle_outline,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                childCount: filteredProducts.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}