import 'package:flutter/material.dart';
import 'product_list_page.dart';
import 'session_list_page.dart';
import 'order_history_page.dart';
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

  List<Product> products = [
    Product(
      id: '1',
      name: 'Yoga Mat',
      description: 'Comfortable and durable yoga mat.',
      category: 'Fitness',
      price: 29.99,
      imageUrl: 'https://example.com/yoga_mat.png',
      isWishlisted: false,
    ),
    Product(
      id: '2',
      name: 'Dumbbells',
      description: 'Adjustable dumbbells for weight training.',
      category: 'Fitness',
      price: 49.99,
      imageUrl: 'https://example.com/dumbbells.png',
      isWishlisted: false,
    ),
  ];

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

  void addToCart(Product product) {
    setState(() {
      cart.add(product);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} added to cart')),
    );
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
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        title: const Text(
          'SLINK Home',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.white),
            onPressed: () {
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
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartPage(
                    cartItems: cart,
                    onRemoveFromCart: (product) {
                      setState(() {
                        cart.remove(product);
                      });
                    },
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserProfilePage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildBanner(),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                _buildActionButton(
                  icon: Icons.shopping_bag,
                  label: 'Shop Products',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductListPage(
                          products: products,
                          onAddToCart: widget.addToCart,
                          onWishlistToggle: toggleWishlist,
                          wishlist: widget.wishlist,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildActionButton(
                  icon: Icons.schedule,
                  label: 'Book a Session',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SessionListPage()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildActionButton(
                  icon: Icons.history,
                  label: 'Order History',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => OrderHistoryPage()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildActionButton(
                  icon: Icons.person,
                  label: 'User Profile',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UserProfilePage()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 24, color: Colors.white),
      label: Text(label,
          style: const TextStyle(fontSize: 18, color: Colors.white)),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: Colors.blue[800],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.blue[100],
        image: const DecorationImage(
          image: NetworkImage('https://example.com/banner.png'),
          fit: BoxFit.cover,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: const Center(
        child: Text(
          'Welcome to SLINK!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                offset: Offset(0.0, 1.0),
                blurRadius: 3.0,
                color: Color.fromARGB(150, 0, 0, 0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
