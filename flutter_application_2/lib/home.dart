import 'package:flutter/material.dart';
import 'products.dart';
import 'chat_page.dart';
import 'cart_page.dart';
import 'services/cart_service.dart';
import 'widgets/app_header.dart';
import 'widgets/user_greeting.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HydroFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFdc2626), // Red
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CartService _cartService = CartService();

  final List<String> imageUrls = [
    'https://www.infomediasearch.com/media/post/2017/15/7/sabari-hydro-pneumatics158455907315-img.jpg',
    'https://5.imimg.com/data5/NSDMERP/Location/2021/11/BN/KE/NI/1895445/1895445-location-1638011372332-1000x1000.jpg',
    'https://5.imimg.com/data5/NSDMERP/Board/2022/5/GE/JE/YX/1895445/1895445-board-1653300510109-1000x1000.jpg',
    'https://5.imimg.com/data5/NSDMERP/Location/2022/5/JT/XM/YP/1895445/1895445-location-1653300511423-1000x1000.jpg',
  ];

  final List<Map<String, dynamic>> frequentlyPurchased = [
    {
      "name": "Hydraulic Pump",
      "image": "https://shorturl.at/Ovp6D",
      "price": "₹1,25,000",
      "category": "Pumps",
      "description":
          "High-performance hydraulic pump for industrial applications",
      "rating": 4.8,
      "inStock": true,
    },
    {
      "name": "Air Filter",
      "image": "https://shorturl.at/sTrJw",
      "price": "₹8,500",
      "category": "Filters",
      "description": "Premium air filtration system for clean operation",
      "rating": 4.6,
      "inStock": true,
    },
    {
      "name": "Hose Pipe",
      "image":
          "https://5.imimg.com/data5/ANDROID/Default/2023/8/338177897/JS/BV/JX/1895445/product-jpeg-500x500.jpg",
      "price": "₹4,500",
      "category": "Connections",
      "description": "Durable hydraulic hose for high-pressure systems",
      "rating": 4.7,
      "inStock": true,
    },
    {
      "name": "Gear Coupling",
      "image":
          "https://5.imimg.com/data5/NSDMERP/Default/2023/3/OQ/UQ/HK/1895445/flexible-drive-gear-coupling-1678173692042-500x500.jpg",
      "price": "₹32,000",
      "category": "Couplings",
      "description": "Flexible gear coupling for smooth power transmission",
      "rating": 4.9,
      "inStock": false,
    },
  ];

  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);
    _cartService.addListener(_onCartChanged);

    Future.delayed(Duration.zero, () async {
      while (mounted) {
        await Future.delayed(const Duration(seconds: 3));
        if (_pageController.hasClients) {
          _currentPage = (_currentPage + 1) % imageUrls.length;
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
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
          backgroundColor: Color(0xFFdc2626),
        ),
      );
      return;
    }

    final cartItem = CartItem(
      id: product["name"],
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
        backgroundColor: const Color(0xFF059669),
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

  Widget _buildQuickActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.15), color.withOpacity(0.08)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.8),
              blurRadius: 8,
              offset: const Offset(-2, -2),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: -0.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    String status,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.12), color.withOpacity(0.06)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.9),
            blurRadius: 10,
            offset: const Offset(-3, -3),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.25), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 16),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.9)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6b7280).withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String description,
    String time,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1e3a8a),
                ),
              ),
              Text(
                description,
                style: const TextStyle(fontSize: 12, color: Color(0xFF6b7280)),
              ),
            ],
          ),
        ),
        Text(
          time,
          style: const TextStyle(fontSize: 11, color: Color(0xFF9ca3af)),
        ),
      ],
    );
  }

  Widget _buildMaintenanceItem(
    String title,
    String description,
    String timeLeft,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1e3a8a),
                ),
              ),
              Text(
                description,
                style: const TextStyle(fontSize: 12, color: Color(0xFF6b7280)),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            timeLeft,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  void _showEmergencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.warning, color: Color(0xFFdc2626)),
                SizedBox(width: 8),
                Text('Emergency Stop'),
              ],
            ),
            content: const Text(
              'Are you sure you want to initiate an emergency stop? This will immediately halt all hydraulic operations.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFdc2626),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Emergency stop activated!'),
                      backgroundColor: Color(0xFFdc2626),
                    ),
                  );
                },
                child: const Text(
                  'Emergency Stop',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _showDiagnosticsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.health_and_safety, color: Color(0xFF059669)),
                SizedBox(width: 8),
                Text('System Diagnostics'),
              ],
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('✅ Hydraulic Pump: Operational'),
                Text('✅ Pressure System: Normal'),
                Text('✅ Temperature: Within Range'),
                Text('✅ Flow Rate: Optimal'),
                Text('⚠️ Filter: Needs Attention'),
                SizedBox(height: 12),
                Text(
                  'Overall System Health: 95%',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Full diagnostic report generated'),
                    ),
                  );
                },
                child: const Text('Generate Report'),
              ),
            ],
          ),
    );
  }

  void _showMaintenanceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.schedule, color: Color(0xFF0891b2)),
                SizedBox(width: 8),
                Text('Maintenance Schedule'),
              ],
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upcoming Maintenance:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('• Oil Change - Due in 3 days'),
                Text('• Filter Inspection - Due in 1 week'),
                Text('• System Calibration - Due in 2 weeks'),
                Text('• Annual Service - Due in 2 months'),
                SizedBox(height: 12),
                Text('Last Maintenance: Filter replacement (1 day ago)'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Maintenance reminder set')),
                  );
                },
                child: const Text('Set Reminder'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          // Sticky Header
          const AppHeader(
            title: 'HydroFlow',
            subtitle: 'Hydraulic System Control',
          ),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // User Greeting now scrolls with content
                  const UserGreeting(),

                  // Enhanced System Status Card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFdc2626),
                          Color(0xFFb91c1c),
                          Color(0xFF991b1b),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFdc2626).withOpacity(0.4),
                          blurRadius: 25,
                          offset: const Offset(0, 12),
                        ),
                        BoxShadow(
                          color: const Color(0xFFdc2626).withOpacity(0.2),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'System Status',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Last updated: ${DateTime.now().toString().substring(0, 16)}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'All Systems Operational',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              '98%',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Efficiency',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Enhanced Image Carousel
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ShaderMask(
                            shaderCallback:
                                (bounds) => const LinearGradient(
                                  colors: [
                                    Color(0xFF1e3a8a),
                                    Color(0xFF3b82f6),
                                  ],
                                ).createShader(bounds),
                            child: const Text(
                              'System Gallery',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 220,
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: imageUrls.length,
                            itemBuilder: (context, index) {
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.25),
                                      blurRadius: 30,
                                      offset: const Offset(0, 15),
                                    ),
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, -5),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: Stack(
                                    children: [
                                      // Main image
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(24),
                                        child: Image.network(
                                          imageUrls[index],
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                          errorBuilder:
                                              (
                                                context,
                                                error,
                                                stackTrace,
                                              ) => Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: [
                                                      Colors.grey[200]!,
                                                      Colors.grey[300]!,
                                                    ],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(24),
                                                ),
                                                child: const Center(
                                                  child: Icon(
                                                    Icons.image_not_supported,
                                                    size: 50,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                        ),
                                      ),
                                      // Subtle border glow
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(
                                              0.3,
                                            ),
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Enhanced Carousel indicators
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            imageUrls.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: _currentPage == index ? 32 : 12,
                              height: 12,
                              decoration: BoxDecoration(
                                gradient:
                                    _currentPage == index
                                        ? const LinearGradient(
                                          colors: [
                                            Color(0xFF1e3a8a),
                                            Color(0xFF3b82f6),
                                          ],
                                        )
                                        : null,
                                color:
                                    _currentPage == index
                                        ? null
                                        : Colors.grey[300]?.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(6),
                                boxShadow:
                                    _currentPage == index
                                        ? [
                                          BoxShadow(
                                            color: const Color(
                                              0xFF1e3a8a,
                                            ).withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                        : null,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Enhanced Frequently Purchased Section
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.9),
                          Colors.white.withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.8),
                          blurRadius: 10,
                          offset: const Offset(-5, -5),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1e3a8a).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.inventory_2,
                                color: Color(0xFF1e3a8a),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Frequently Purchased',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1e3a8a),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ProductsPage(),
                                  ),
                                );
                              },
                              child: const Text(
                                'View All',
                                style: TextStyle(
                                  color: Color(0xFFdc2626),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 140,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            itemCount: frequentlyPurchased.length,
                            itemBuilder: (context, index) {
                              final item = frequentlyPurchased[index];
                              return Container(
                                width: 110,
                                margin: EdgeInsets.only(
                                  right:
                                      index == frequentlyPurchased.length - 1
                                          ? 4
                                          : 12,
                                  left: index == 0 ? 4 : 0,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Stack(
                                    children: [
                                      // Background image
                                      Image.network(
                                        item["image"]!,
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (
                                              context,
                                              error,
                                              stackTrace,
                                            ) => Container(
                                              width: double.infinity,
                                              height: double.infinity,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: const Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.image_not_supported,
                                                    size: 30,
                                                    color: Colors.grey,
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    'No Image',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                      ),
                                      // Text overlay
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(12),
                                              bottomRight: Radius.circular(12),
                                            ),
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.transparent,
                                                Colors.black,
                                              ],
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                item["name"]!,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                  shadows: [
                                                    Shadow(
                                                      offset: Offset(0, 1),
                                                      blurRadius: 2,
                                                      color: Colors.black,
                                                    ),
                                                  ],
                                                ),
                                                textAlign: TextAlign.center,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    item["price"]!,
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap:
                                                        () => _addToCart(item),
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            4,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            item["inStock"]
                                                                ? const Color(
                                                                  0xFFdc2626,
                                                                )
                                                                : Colors
                                                                    .grey[600],
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              6,
                                                            ),
                                                      ),
                                                      child: Icon(
                                                        _cartService.isInCart(
                                                              item["name"],
                                                            )
                                                            ? Icons.check
                                                            : Icons
                                                                .add_shopping_cart,
                                                        color: Colors.white,
                                                        size: 12,
                                                      ),
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
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Enhanced Quick Actions Section
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.95),
                          Colors.white.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 25,
                          offset: const Offset(0, 12),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.9),
                          blurRadius: 15,
                          offset: const Offset(-8, -8),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1e3a8a).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.flash_on,
                                color: Color(0xFF1e3a8a),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Quick Actions',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1e3a8a),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        GridView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                mainAxisExtent: 150,
                              ),
                          children: [
                            _buildQuickActionButton(
                              'Emergency\nStop',
                              Icons.emergency,
                              const Color(0xFFdc2626),
                              () => _showEmergencyDialog(context),
                            ),
                            _buildQuickActionButton(
                              'System\nDiagnostics',
                              Icons.health_and_safety,
                              const Color(0xFF059669),
                              () => _showDiagnosticsDialog(context),
                            ),
                            _buildQuickActionButton(
                              'Maintenance\nSchedule',
                              Icons.schedule,
                              const Color(0xFF0891b2),
                              () => _showMaintenanceDialog(context),
                            ),
                            _buildQuickActionButton(
                              'Ask AI\nAssistant',
                              Icons.smart_toy,
                              const Color(0xFF7c3aed),
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ChatPage(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // System Metrics Overview
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.95),
                          Colors.white.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 25,
                          offset: const Offset(0, 12),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.9),
                          blurRadius: 15,
                          offset: const Offset(-8, -8),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1e3a8a).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.analytics,
                                color: Color(0xFF1e3a8a),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'System Metrics',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1e3a8a),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildMetricCard(
                                'Pressure',
                                '2.4 MPa',
                                'Normal',
                                Icons.speed,
                                const Color(0xFF059669),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildMetricCard(
                                'Temperature',
                                '45°C',
                                'Optimal',
                                Icons.thermostat,
                                const Color(0xFF0891b2),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildMetricCard(
                                'Flow Rate',
                                '45.2 L/min',
                                'Good',
                                Icons.water_drop,
                                const Color(0xFF7c3aed),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildMetricCard(
                                'Vibration',
                                '0.2 mm/s',
                                'Low',
                                Icons.vibration,
                                const Color(0xFF059669),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Enhanced Recent Activity Feed
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.95),
                          Colors.white.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 25,
                          offset: const Offset(0, 12),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.9),
                          blurRadius: 15,
                          offset: const Offset(-8, -8),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1e3a8a).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.history,
                                color: Color(0xFF1e3a8a),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Recent Activity',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1e3a8a),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildActivityItem(
                          'System Startup',
                          'All systems initialized successfully',
                          '2 hours ago',
                          Icons.power_settings_new,
                          const Color(0xFF059669),
                        ),
                        const SizedBox(height: 12),
                        _buildActivityItem(
                          'Pressure Check',
                          'Routine pressure monitoring completed',
                          '4 hours ago',
                          Icons.check_circle,
                          const Color(0xFF0891b2),
                        ),
                        const SizedBox(height: 12),
                        _buildActivityItem(
                          'Filter Maintenance',
                          'Hydraulic filter replaced successfully',
                          '1 day ago',
                          Icons.build,
                          const Color(0xFF7c3aed),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Enhanced Maintenance Reminders
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.95),
                          Colors.white.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 25,
                          offset: const Offset(0, 12),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.9),
                          blurRadius: 15,
                          offset: const Offset(-8, -8),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFdc2626).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.notification_important,
                                color: Color(0xFFdc2626),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Maintenance Reminders',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1e3a8a),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildMaintenanceItem(
                          'Oil Change Due',
                          'Hydraulic oil replacement needed',
                          '3 days',
                          Icons.oil_barrel,
                          const Color(0xFFdc2626),
                        ),
                        const SizedBox(height: 12),
                        _buildMaintenanceItem(
                          'Filter Inspection',
                          'Check hydraulic filter condition',
                          '1 week',
                          Icons.filter_alt,
                          const Color(0xFFf59e0b),
                        ),
                        const SizedBox(height: 12),
                        _buildMaintenanceItem(
                          'System Calibration',
                          'Annual system calibration due',
                          '2 weeks',
                          Icons.tune,
                          const Color(0xFF059669),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Performance Analytics
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.95),
                          Colors.white.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 25,
                          offset: const Offset(0, 12),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.9),
                          blurRadius: 15,
                          offset: const Offset(-8, -8),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1e3a8a).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.trending_up,
                                color: Color(0xFF1e3a8a),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Performance Analytics',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1e3a8a),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildAnalyticsCard(
                                'Daily Output',
                                '1,247 L',
                                '+12%',
                                Icons.water_drop,
                                const Color(0xFF0891b2),
                                true,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildAnalyticsCard(
                                'Energy Usage',
                                '45.2 kWh',
                                '-8%',
                                Icons.bolt,
                                const Color(0xFFf59e0b),
                                false,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildAnalyticsCard(
                                'Uptime',
                                '99.2%',
                                '+0.5%',
                                Icons.schedule,
                                const Color(0xFF059669),
                                true,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildAnalyticsCard(
                                'Cost Savings',
                                '₹1,23,400',
                                '+15%',
                                Icons.savings,
                                const Color(0xFF7c3aed),
                                true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Industry News & Tips
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.95),
                          Colors.white.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 25,
                          offset: const Offset(0, 12),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.9),
                          blurRadius: 15,
                          offset: const Offset(-8, -8),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFdc2626).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.newspaper,
                                color: Color(0xFFdc2626),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Industry Updates',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1e3a8a),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildNewsItem(
                          'New Hydraulic Safety Standards Released',
                          'Updated ISO 4413 standards now available for industrial hydraulic systems.',
                          '2 hours ago',
                          Icons.security,
                          const Color(0xFFdc2626),
                        ),
                        const SizedBox(height: 12),
                        _buildNewsItem(
                          'Energy Efficiency Tips',
                          'Learn how to reduce hydraulic system energy consumption by up to 20%.',
                          '1 day ago',
                          Icons.eco,
                          const Color(0xFF059669),
                        ),
                        const SizedBox(height: 12),
                        _buildNewsItem(
                          'Preventive Maintenance Guide',
                          'Best practices for extending hydraulic component lifespan.',
                          '3 days ago',
                          Icons.build,
                          const Color(0xFF0891b2),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1e3a8a),
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
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.home, color: Color(0xFFdc2626), size: 20),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatPage()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFdc2626), Color(0xFFb91c1c)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFdc2626).withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProductsPage()),
                );
              },
              child: const Icon(
                Icons.inventory_2,
                color: Colors.white,
                size: 20,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartPage()),
                );
              },
              child: Stack(
                children: [
                  const Icon(
                    Icons.shopping_cart,
                    color: Colors.white,
                    size: 20,
                  ),
                  if (_cartService.itemCount > 0)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Color(0xFFdc2626),
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${_cartService.itemCount}',
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsCard(
    String title,
    String value,
    String change,
    IconData icon,
    Color color,
    bool isPositive,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.12), color.withOpacity(0.06)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.9),
            blurRadius: 10,
            offset: const Offset(-3, -3),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.25), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 16),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      isPositive
                          ? const Color(0xFF059669)
                          : const Color(0xFFdc2626),
                      isPositive
                          ? const Color(0xFF059669).withOpacity(0.9)
                          : const Color(0xFFdc2626).withOpacity(0.9),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: (isPositive
                              ? const Color(0xFF059669)
                              : const Color(0xFFdc2626))
                          .withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                      color: Colors.white,
                      size: 10,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      change,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6b7280).withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsItem(
    String title,
    String description,
    String time,
    IconData icon,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1e3a8a),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(fontSize: 12, color: Color(0xFF6b7280)),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withOpacity(0.3), width: 1),
                ),
                child: Text(
                  time,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

extension ColorOpacity on Color {
  Color withOpacity(double opacity) {
    return this.withAlpha((255 * opacity).round());
  }
}
