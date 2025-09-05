import 'package:flutter/material.dart';
import 'cart_page.dart';
import 'services/cart_service.dart';
import 'widgets/app_header.dart';
import 'widgets/glass_container.dart';
import 'theme/app_colors.dart';
import 'widgets/app_bottom_navigation.dart';

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
            : products.where((p) => p["category"] == selectedCategory).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          const AppHeader(
            title: 'Our Products',
            subtitle: 'Browse our extensive catalog',
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildCategoryFilter(),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.62,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return GlassContainer(
                        borderRadius: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 5,
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
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                                Icons.image_not_supported,
                                              ),
                                    ),
                                    if (!product["inStock"])
                                      Container(
                                        color: Colors.black.withAlpha(128),
                                        child: const Center(
                                          child: Text(
                                            'Out of Stock',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product["category"],
                                      style: Theme.of(
                                        context,
                                      ).textTheme.labelSmall?.copyWith(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Expanded(
                                      child: Text(
                                        product["name"],
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.titleMedium,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: true,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            product["price"],
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleMedium?.copyWith(
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        IconButton(
                                          onPressed: () => _addToCart(product),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(
                                            minWidth: 32,
                                            minHeight: 32,
                                          ),
                                          icon: Icon(
                                            _cartService.isInCart(
                                                  product["name"],
                                                )
                                                ? Icons.check_circle
                                                : Icons.add_circle_outline,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                            size: 20,
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
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentPage: 'products',
        cartService: _cartService,
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border:
                    isSelected
                        ? null
                        : Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withAlpha(26),
                        ),
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    color:
                        isSelected
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
    );
  }
}
