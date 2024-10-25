import 'package:flutter/material.dart';
// import 'product_list_page.dart';
// import 'session_list_page.dart';
// import 'order_history_page.dart';
import 'user_profile_page.dart';
import 'wishlist_page.dart';
import 'cart_page.dart';
import '../models/product.dart';

class HomePage extends StatefulWidget {
  final List<Product> wishlist;
  final Function(Product) addToCart;

  const HomePage({super.key, required this.wishlist, required this.addToCart});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Product> cart = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    // Placeholder for future database calls
    setState(() {
      isLoading = true;
    });

    try {
      // Simulate loading time
      await Future.delayed(const Duration(seconds: 1));
      // Here you'll fetch data from your database
      // products = await productService.getFeaturedProducts();
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void toggleWishlist(Product product) {
    setState(() {
      product.isWishlisted = !product.isWishlisted;
      if (product.isWishlisted) {
        widget.wishlist.add(product);
      } else {
        widget.wishlist.remove(product);
      }
    });
  }

  void removeFromCart(Product product) {
    setState(() {
      cart.remove(product);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} removed from cart')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _loadInitialData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBanner(),
              const SizedBox(height: 20),
              _buildFeatureCards(),
              const SizedBox(height: 20),
              _buildSectionTitle('Quick Actions'),
              _buildQuickActions(),
              const SizedBox(height: 20),
              _buildSectionTitle('Featured Products'),
              _buildFeaturedProducts(),
              const SizedBox(height: 20),
              _buildSectionTitle('Upcoming Sessions'),
              _buildUpcomingSessions(),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.blue[800],
      title: const Text(
        '', //'SLINK'
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
          letterSpacing: 1.5,
        ),
      ),
      actions: [
        _buildAppBarAction(Icons.favorite, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WishlistPage(
                wishlist: widget.wishlist,
                onAddToCart: widget.addToCart,
                onWishlistToggle: toggleWishlist,
              ),
            ),
          );
        }, widget.wishlist.length),
        _buildAppBarAction(Icons.shopping_cart, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CartPage(
                cartItems: cart,
                onRemoveFromCart: removeFromCart,
              ),
            ),
          );
        }, cart.length),
        IconButton(
          icon: const Icon(Icons.person, color: Colors.white),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UserProfilePage()),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBarAction(IconData icon, VoidCallback onPressed, int count) {
    return Stack(
      children: [
        IconButton(
          icon: Icon(icon, color: Colors.white),
          onPressed: onPressed,
        ),
        if (count > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBanner() {
    return Container(
      height: 200,
      width: double.infinity,
      child: Stack(
        children: [
          // Replace with Image.asset
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue[800]!,
                  Colors.blue[400]!,
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.black.withOpacity(0.1),
                ],
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Welcome to SLINK',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 2),
                        blurRadius: 4,
                        color: Colors.black45,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your Fitness Journey Starts Here',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    shadows: const [
                      Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 2,
                        color: Colors.black45,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCards() {
    return Container(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildFeatureCard(
            'Shop',
            Icons.shopping_bag,
            Colors.blue[800]!,
            () => Navigator.pushNamed(context, '/products'),
          ),
          _buildFeatureCard(
            'Sessions',
            Icons.calendar_today,
            Colors.green[700]!,
            () => Navigator.pushNamed(context, '/sessions'),
          ),
          _buildFeatureCard(
            'Orders',
            Icons.receipt_long,
            Colors.orange[800]!,
            () => Navigator.pushNamed(context, '/orders'),
          ),
          _buildFeatureCard(
            'Profile',
            Icons.person,
            Colors.purple[800]!,
            () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 100,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Add the remaining widgets...
  // _buildSectionTitle
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // _buildQuickActions
  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildQuickActionCard(
            'Shop Now',
            Icons.shopping_bag_outlined,
            Colors.blue[800]!,
            () => Navigator.pushNamed(context, '/products'),
          ),
          _buildQuickActionCard(
            'Book Session',
            Icons.calendar_today_outlined,
            Colors.green[700]!,
            () => Navigator.pushNamed(context, '/sessions'),
          ),
          _buildQuickActionCard(
            'My Orders',
            Icons.receipt_long_outlined,
            Colors.orange[800]!,
            () => Navigator.pushNamed(context, '/orders'),
          ),
          _buildQuickActionCard(
            'My Profile',
            Icons.person_outline,
            Colors.purple[800]!,
            () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedProducts() {
    // Placeholder for featured products
    return Container(
      height: 200,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5, // Replace with actual product count
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(right: 16),
            child: Container(
              width: 160,
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Center(
                      child: Icon(Icons.fitness_center,
                          size: 48, color: Colors.blue[800]),
                    ),
                  ),
                  const Text(
                    'Product Name',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '\R999.99',
                    style: TextStyle(color: Colors.blue[800]),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

// _buildUpcomingSessions

  Widget _buildUpcomingSessions() {
    // Placeholder for upcoming sessions
    return Container(
      height: 150,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3, // Replace with actual session count
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(right: 16),
            child: Container(
              width: 200,
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Session ${index + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text('Upcoming Date'),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Book Now'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
