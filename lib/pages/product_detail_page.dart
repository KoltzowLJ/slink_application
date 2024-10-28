// lib/pages/product_detail_page.dart

import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;
  final Function(Product) onAddToCart;

  const ProductDetailPage(
      {super.key, required this.product, required this.onAddToCart});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  // Controllers and state variables
  final _reviewController = TextEditingController();
  double _rating = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  // App Bar
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.blue[800],
      title: Text(widget.product.name),
    );
  }

  // Main body content
  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductImage(),
          const SizedBox(height: 16.0),
          _buildProductDetails(),
          const SizedBox(height: 16.0),
          _buildAddToCartButton(),
          const SizedBox(height: 16.0),
          Expanded(child: _buildReviewSection()),
          _buildReviewForm(),
        ],
      ),
    );
  }

  // Product image widget
  Widget _buildProductImage() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          widget.product.imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 200,
        ),
      ),
    );
  }

  // Product details section
  Widget _buildProductDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product name
        Text(
          widget.product.name,
          style: const TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8.0),

        // Product price
        Text(
          'R${widget.product.price}',
          style: TextStyle(
            fontSize: 22.0,
            color: Colors.green[700],
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16.0),

        // Product description
        Text(
          widget.product.description,
          style: TextStyle(fontSize: 16.0, color: Colors.grey[700]),
        ),
      ],
    );
  }

  // Add to cart button
  Widget _buildAddToCartButton() {
    return ElevatedButton(
      onPressed: _handleAddToCart,
      style: _buildButtonStyle(),
      child: const Text('Add to Cart'),
    );
  }

  // Reviews section
  Widget _buildReviewSection() {
    return widget.product.reviews.isEmpty
        ? const Center(child: Text('No reviews yet. Be the first to review!'))
        : ListView.builder(
            itemCount: widget.product.reviews.length,
            itemBuilder: (context, index) => _buildReviewItem(index),
          );
  }

  // Individual review item
  Widget _buildReviewItem(int index) {
    final review = widget.product.reviews[index];
    return ListTile(
      leading: Icon(Icons.person, color: Colors.blue[800]),
      title: Text(
        review.user,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        '${review.comment}\nRating: ${review.rating}',
        style: TextStyle(color: Colors.grey[600]),
      ),
    );
  }

  // Review form
  Widget _buildReviewForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Review text field
        TextField(
          controller: _reviewController,
          decoration: const InputDecoration(
            labelText: 'Leave a review',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        // Rating slider
        _buildRatingSlider(),
        const SizedBox(height: 16),

        // Submit button
        ElevatedButton(
          onPressed: _handleSubmitReview,
          style: _buildButtonStyle(),
          child: const Text('Submit Review'),
        ),
      ],
    );
  }

  // Rating slider widget
  Widget _buildRatingSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rate this product',
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
        Slider(
          value: _rating,
          min: 0,
          max: 5,
          divisions: 5,
          onChanged: (value) => setState(() => _rating = value),
          label: _rating.toString(),
        ),
      ],
    );
  }

  // Common button style
  ButtonStyle _buildButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.blue[800],
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  // Handler methods
  void _handleAddToCart() {
    widget.onAddToCart(widget.product);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Added to Cart!')),
    );
  }

  void _handleSubmitReview() {
    if (_reviewController.text.isNotEmpty && _rating > 0) {
      setState(() {
        widget.product.reviews.add(
          Review(
            user: 'John Doe',
            comment: _reviewController.text,
            rating: _rating,
          ),
        );
        _reviewController.clear();
        _rating = 0;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a review and rating!')),
      );
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }
}
