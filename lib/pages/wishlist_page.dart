// lib/pages/wishlist_page.dart

import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/product_tile.dart';

class WishlistPage extends StatelessWidget {
  // Properties
  final List<Product> wishlist;
  final Function(Product) onAddToCart;
  final Function(Product) onWishlistToggle;

  // Constants
  static const double _padding = 16.0;
  static const double _emptyIconSize = 80.0;
  static const double _emptyTextSize = 24.0;
  static const double _buttonPaddingVertical = 14.0;
  static const double _buttonPaddingHorizontal = 20.0;
  static const double _borderRadius = 12.0;

  const WishlistPage({
    super.key,
    required this.wishlist,
    required this.onAddToCart,
    required this.onWishlistToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(context),
    );
  }

  // App Bar
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.blue[800],
      title: const Text('My Wishlist'),
    );
  }

  // Main body content
  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(_padding),
      child: wishlist.isEmpty
          ? _buildEmptyWishlist(context)
          : _buildWishlistItems(),
    );
  }

  // Wishlist items list
  Widget _buildWishlistItems() {
    return ListView.builder(
      itemCount: wishlist.length,
      itemBuilder: (context, index) {
        return _buildWishlistItem(wishlist[index]);
      },
    );
  }

  // Individual wishlist item
  Widget _buildWishlistItem(Product product) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ProductTile(
        product: product,
        onWishlistToggle: onWishlistToggle,
        onAddToCart: onAddToCart,
      ),
    );
  }

  // Empty wishlist state
  Widget _buildEmptyWishlist(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildEmptyIcon(),
          const SizedBox(height: _padding),
          _buildEmptyText(),
          const SizedBox(height: _padding),
          _buildShopNowButton(context),
        ],
      ),
    );
  }

  // Empty state icon
  Widget _buildEmptyIcon() {
    return Icon(
      Icons.favorite_border,
      size: _emptyIconSize,
      color: Colors.grey[400],
    );
  }

  // Empty state text
  Widget _buildEmptyText() {
    return Text(
      'Your wishlist is empty',
      style: TextStyle(
        fontSize: _emptyTextSize,
        color: Colors.grey[600],
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Shop now button
  Widget _buildShopNowButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _navigateToProducts(context),
      style: _buildButtonStyle(),
      child: const Text('Shop Now'),
    );
  }

  // Button style
  ButtonStyle _buildButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.blue[800],
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(
        vertical: _buttonPaddingVertical,
        horizontal: _buttonPaddingHorizontal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
    );
  }

  // Navigation
  void _navigateToProducts(BuildContext context) {
    Navigator.pushNamed(context, '/products');
  }
}
