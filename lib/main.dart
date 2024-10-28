import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/product.dart';
// Import all pages
import 'pages/splash_screen.dart';
import 'pages/home_page.dart';
import 'pages/cart_page.dart';
import 'pages/user_profile_page.dart';
import 'pages/wishlist_page.dart';
import 'pages/product_list_page.dart';
import 'pages/login_page.dart';
import 'pages/sign_in_page.dart';
import 'pages/sign_up_page.dart';
import 'pages/bookings_page.dart';
import 'pages/order_history_page.dart';
// Import admin pages
import 'pages/admin/admin_home_page.dart';
import 'pages/admin/manage_products_page.dart';
import 'pages/admin/manage_bookings_page.dart';
import 'pages/admin/manage_orders_page.dart';
import 'pages/admin/manage_users_page.dart';

/// Entry point of the application
void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Configure Firestore settings
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  runApp(const SlinkApp());
}

/// Main application widget
class SlinkApp extends StatefulWidget {
  const SlinkApp({super.key});

  @override
  _SlinkAppState createState() => _SlinkAppState();
}

class _SlinkAppState extends State<SlinkApp> {
  // State variables for cart and wishlist
  List<Product> wishlist = [];
  List<Product> cart = [];

  /// Add a product to the cart
  void addToCart(Product product) {
    setState(() {
      cart.add(product);
    });
    _showSnackBar('${product.name} added to cart');
  }

  /// Remove a product from the cart
  void removeFromCart(Product product) {
    setState(() {
      cart.remove(product);
    });
    _showSnackBar('${product.name} removed from cart');
  }

  /// Toggle product in wishlist
  void toggleWishlist(Product product) {
    setState(() {
      if (wishlist.contains(product)) {
        wishlist.remove(product);
      } else {
        wishlist.add(product);
      }
    });
  }

  /// Show a snackbar with a message
  void _showSnackBar(String message) {
    final messengerState = ScaffoldMessenger.of(context);
    messengerState.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SLINK E-Commerce',
      theme: _buildTheme(),
      home: const SplashScreen(),
      routes: _buildRoutes(),
      onGenerateRoute: _handleUnknownRoute,
    );
  }

  /// Build the app theme
  ThemeData _buildTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        primary: Colors.blue[800]!,
        brightness: Brightness.light,
      ),
      textTheme: TextTheme(
        displayLarge: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Colors.grey[800],
        ),
      ),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      outlinedButtonTheme: _buildOutlinedButtonTheme(),
    );
  }

  /// Build elevated button theme
  ElevatedButtonThemeData _buildElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      ),
    );
  }

  /// Build outlined button theme
  OutlinedButtonThemeData _buildOutlinedButtonTheme() {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.blue[800],
        side: BorderSide(color: Colors.blue[800]!),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      ),
    );
  }

  /// Build app routes
  Map<String, WidgetBuilder> _buildRoutes() {
    return {
      '/login': (context) => const LoginPage(),
      '/signin': (context) => const SignInPage(),
      '/signup': (context) => const SignUpPage(),
      '/home': (context) => HomePage(
            wishlist: wishlist,
            addToCart: addToCart,
          ),
      '/cart': (context) => CartPage(
            cartItems: cart,
            onRemoveFromCart: removeFromCart,
          ),
      '/profile': (context) => const UserProfilePage(),
      '/wishlist': (context) => WishlistPage(
            wishlist: wishlist,
            onAddToCart: addToCart,
            onWishlistToggle: toggleWishlist,
          ),
      '/products': (context) => ProductListPage(
            onAddToCart: addToCart,
            onWishlistToggle: toggleWishlist,
            wishlist: wishlist,
          ),
      '/bookings': (context) => const BookingsPage(),
      '/orders': (context) => OrderHistoryPage(),
      // Admin routes
      '/admin': (context) => const AdminHomePage(),
      '/admin/products': (context) => const ManageProductsPage(),
      '/admin/bookings': (context) => const ManageBookingsPage(),
      '/admin/orders': (context) => const ManageOrdersPage(),
      '/admin/users': (context) => const ManageUsersPage(),
    };
  }

  /// Handle unknown routes
  Route<dynamic> _handleUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => const Scaffold(
        body: Center(
          child: Text('Page not found'),
        ),
      ),
    );
  }
}
