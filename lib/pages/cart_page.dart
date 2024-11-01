// lib/pages/cart_page.dart

import 'package:flutter/material.dart';
import '../models/product.dart';
import '../pages/checkout_form_page.dart';

class CartPage extends StatefulWidget {
  final List<Product> cartItems;
  final Function(Product) onRemoveFromCart;

  const CartPage({
    super.key,
    required this.cartItems,
    required this.onRemoveFromCart,
  });

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // Calculate total price of items in cart
  double get totalPrice {
    return widget.cartItems.fold(0, (sum, item) => sum + item.price);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App Bar
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        backgroundColor: Colors.blue[800],
      ),

      // Main body - shows empty message or cart items
      body: widget.cartItems.isEmpty
          ? const Center(child: Text('Your cart is empty'))
          : Column(
              children: [
                // List of cart items
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.cartItems.length,
                    itemBuilder: (context, index) {
                      final product = widget.cartItems[index];
                      return _buildCartItem(product);
                    },
                  ),
                ),
                // Cart summary and checkout button
                _buildCartSummary(),
              ],
            ),
    );
  }

  // Individual cart item widget
  Widget _buildCartItem(Product product) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Product image
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  product.imageUrl,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 8),

              // Product name
              Text(
                product.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Product price
              Text(
                'R${product.price.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.green[700],
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Remove from cart button
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    widget.onRemoveFromCart(product);
                  });
                },
                icon: const Icon(Icons.remove_circle, color: Colors.white),
                label: const Text('Remove from Cart'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Cart summary widget with total and checkout button
  Widget _buildCartSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          // Total price row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'R${totalPrice.toStringAsFixed(2)}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Checkout button
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CheckoutFormPage(
                    cartItems: widget.cartItems,
                    total: totalPrice,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Colors.blue[800],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Proceed to Checkout'),
          ),
        ],
      ),
    );
  }
}
