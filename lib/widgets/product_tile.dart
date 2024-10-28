// lib/widgets/product_tile.dart

import 'package:flutter/material.dart';
import '../models/product.dart';

// A widget that displays a product in a card format
class ProductTile extends StatelessWidget {
  final Product product;
  final Function(Product) onAddToCart;
  final Function(Product) onWishlistToggle;

  // Constants for styling
  static const double _borderRadius = 12.0;
  static const double _imageSize = 120.0;
  static const double _spacing = 8.0;

  const ProductTile({
    super.key,
    required this.product,
    required this.onAddToCart,
    required this.onWishlistToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
      elevation: 4,
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildProductImage(),
            const SizedBox(height: _spacing),
            _buildProductName(),
            const SizedBox(height: _spacing),
            _buildProductPrice(),
            const SizedBox(height: _spacing),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  // Builds the product image widget
  Widget _buildProductImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_spacing),
      child: Image.network(
        product.imageUrl,
        width: _imageSize,
        height: _imageSize,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: _imageSize,
            height: _imageSize,
            color: Colors.grey[200],
            child: const Icon(
              Icons.error_outline,
              color: Colors.grey,
              size: 40,
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: _imageSize,
            height: _imageSize,
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }

  // Builds the product name widget
  Widget _buildProductName() {
    return Text(
      product.name,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    );
  }

  // Builds the product price widget
  Widget _buildProductPrice() {
    return Text(
      _formatPrice(product.price),
      style: TextStyle(
        fontSize: 16,
        color: Colors.green[700],
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  // Builds the action buttons (wishlist and cart)
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildWishlistButton(),
        _buildAddToCartButton(),
      ],
    );
  }

  // Builds the wishlist toggle button
  Widget _buildWishlistButton() {
    return IconButton(
      icon: Icon(
        product.isWishlisted ? Icons.favorite : Icons.favorite_border,
        color: product.isWishlisted ? Colors.red : Colors.grey[700],
      ),
      onPressed: () => onWishlistToggle(product),
      tooltip: 'Add to Wishlist',
    );
  }

  // Builds the add to cart button
  Widget _buildAddToCartButton() {
    return IconButton(
      icon: Icon(
        Icons.add_shopping_cart,
        color: Colors.blue[800],
      ),
      onPressed: () => onAddToCart(product),
      tooltip: 'Add to Cart',
    );
  }

  // Formats the price with currency symbol
  String _formatPrice(double price) {
    return 'R${price.toStringAsFixed(2)}';
  }
}
