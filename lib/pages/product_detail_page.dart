import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;
  final Function(Product) onAddToCart;

  ProductDetailPage({required this.product, required this.onAddToCart});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final _reviewController = TextEditingController();
  double _rating = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        title: Text(widget.product.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductImage(),
            SizedBox(height: 16.0),
            _buildProductDetails(),
            SizedBox(height: 16.0),
            _buildAddToCartButton(),
            SizedBox(height: 16.0),
            Expanded(child: _buildReviewSection()),
            _buildReviewForm(),
          ],
        ),
      ),
    );
  }

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

  Widget _buildProductDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.product.name,
          style: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8.0),
        Text(
          '\R${widget.product.price}',
          style: TextStyle(
            fontSize: 22.0,
            color: Colors.green[700],
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.0),
        Text(
          widget.product.description,
          style: TextStyle(fontSize: 16.0, color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _buildAddToCartButton() {
    return ElevatedButton(
      onPressed: () {
        widget.onAddToCart(widget.product);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added to Cart!')),
        );
      },
      child: Text('Add to Cart'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildReviewSection() {
    return widget.product.reviews.isEmpty
        ? Center(child: Text('No reviews yet. Be the first to review!'))
        : ListView.builder(
            itemCount: widget.product.reviews.length,
            itemBuilder: (context, index) {
              final review = widget.product.reviews[index];
              return ListTile(
                leading: Icon(Icons.person, color: Colors.blue[800]),
                title: Text(
                  review.user,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${review.comment}\nRating: ${review.rating}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              );
            },
          );
  }

  Widget _buildReviewForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _reviewController,
          decoration: InputDecoration(
            labelText: 'Leave a review',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Rate this product',
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
        Slider(
          value: _rating,
          min: 0,
          max: 5,
          divisions: 5,
          onChanged: (value) {
            setState(() {
              _rating = value;
            });
          },
          label: _rating.toString(),
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
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
                SnackBar(content: Text('Please provide a review and rating!')),
              );
            }
          },
          child: Text('Submit Review'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[800],
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
