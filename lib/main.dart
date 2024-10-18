import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/cart_page.dart';
import 'models/product.dart';
import 'pages/user_profile_page.dart';
import 'pages/wishlist_page.dart';
import 'pages/product_list_page.dart';

void main() {
  runApp(SlinkApp());
}

class SlinkApp extends StatefulWidget {
  @override
  _SlinkAppState createState() => _SlinkAppState();
}

class _SlinkAppState extends State<SlinkApp> {
  List<Product> wishlist = [];
  List<Product> cart = [];

  void addToCart(Product product) {
    setState(() {
      cart.add(product);
    });
    _showSnackBar('${product.name} added to cart');
  }

  void removeFromCart(Product product) {
    setState(() {
      cart.remove(product);
    });
    _showSnackBar('${product.name} removed from cart');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SLINK E-Commerce',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        textTheme: TextTheme(
          displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(fontSize: 16, color: Colors.grey[800]),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          ),
        ),
      ),
      home: HomePage(
        wishlist: wishlist,
        addToCart: addToCart,
      ),
      routes: {
        '/cart': (context) => CartPage(
              cartItems: cart,
              onRemoveFromCart: removeFromCart,
            ),
        '/profile': (context) => UserProfilePage(),
        '/wishlist': (context) => WishlistPage(
              wishlist: wishlist,
              onAddToCart: addToCart,
              onWishlistToggle: (Product product) {
                setState(() {
                  if (wishlist.contains(product)) {
                    wishlist.remove(product);
                  } else {
                    wishlist.add(product);
                  }
                });
              },
            ),
        '/products': (context) => ProductListPage(
              products: [],
              onAddToCart: addToCart,
              onWishlistToggle: (Product product) {
                setState(() {
                  if (wishlist.contains(product)) {
                    wishlist.remove(product);
                  } else {
                    wishlist.add(product);
                  }
                });
              },
              wishlist: wishlist,
            ),
      },
    );
  }
}
