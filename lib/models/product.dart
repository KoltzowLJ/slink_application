// lib/models/product.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  bool isWishlisted;
  List<Review> reviews;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.isWishlisted = false,
    this.reviews = const [],
  });

  // Add fromFirestore method
  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? '',
      isWishlisted: data['isWishlisted'] ?? false,
      reviews: (data['reviews'] as List<dynamic>?)
              ?.map((review) => Review.fromMap(review as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  // Existing fromMap method
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? '',
      isWishlisted: map['isWishlisted'] ?? false,
      reviews: (map['reviews'] as List<dynamic>?)
              ?.map((review) => Review.fromMap(review as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  // Existing toMap method
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'isWishlisted': isWishlisted,
      'reviews': reviews.map((review) => review.toMap()).toList(),
    };
  }

  String get formattedPrice => 'R${price.toStringAsFixed(2)}';
}

class Review {
  final String user;
  final String comment;
  final double rating;
  final DateTime timestamp;

  Review({
    required this.user,
    required this.comment,
    required this.rating,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      user: map['user'] ?? '',
      comment: map['comment'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user': user,
      'comment': comment,
      'rating': rating,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
