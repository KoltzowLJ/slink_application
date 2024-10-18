import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/product_tile.dart';

class WishlistPage extends StatelessWidget {
  final List<Product> wishlist;
  final Function(Product) onAddToCart;
  final Function(Product) onWishlistToggle;

  WishlistPage({
    required this.wishlist,
    required this.onAddToCart,
    required this.onWishlistToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[800]!,
        title: Text('My Wishlist'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: wishlist.isEmpty
            ? _buildEmptyWishlist(context)
            : ListView.builder(
                itemCount: wishlist.length,
                itemBuilder: (context, index) {
                  final product = wishlist[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ProductTile(
                      product: product,
                      onWishlistToggle: (Product product) {
                        onWishlistToggle(product);
                      },
                      onAddToCart: onAddToCart,
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildEmptyWishlist(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'Your wishlist is empty',
            style: TextStyle(
              fontSize: 24,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/products');
            },
            child: Text('Shop Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[800]!,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
