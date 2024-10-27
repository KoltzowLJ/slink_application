// lib/models/product.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final int stockQuantity;
  final Map<String, dynamic> specifications;
  final List<String> features;
  bool isWishlisted;
  List<Review> reviews;
  final DateTime createdAt;
  final DateTime lastUpdated;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.stockQuantity,
    required this.specifications,
    required this.features,
    required this.isWishlisted,
    required this.reviews,
    required this.createdAt,
    required this.lastUpdated,
  });

// lib/models/product.dart

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    try {
      return Product(
        id: data['id']?.toString() ?? doc.id,
        name: data['name']?.toString() ?? '',
        description: data['description']?.toString() ?? '',
        price: (data['price'] is num ? (data['price'] as num).toDouble() : 0.0),
        imageUrl: data['imageUrl']?.toString() ?? '',
        category: data['category']?.toString() ?? '',
        stockQuantity: (data['stockQuantity'] as num?)?.toInt() ?? 0,
        specifications: (data['specifications'] as Map<String, dynamic>?) ?? {},
        features: List<String>.from(data['features'] ?? []),
        isWishlisted: data['isWishlisted'] as bool? ?? false,
        reviews: ((data['reviews'] ?? []) as List)
            .map((review) => review is Map<String, dynamic>
                ? Review.fromMap(review)
                : Review(
                    user: '',
                    comment: '',
                    rating: 0,
                  ))
            .toList(),
        createdAt:
            (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        lastUpdated:
            (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    } catch (e, stackTrace) {
      print('Error parsing product data: $e');
      print('Stack trace: $stackTrace');
      print('Product data: $data');

      // Return a default product instead of throwing
      return Product(
        id: doc.id,
        name: data['name']?.toString() ?? '',
        description: data['description']?.toString() ?? '',
        price: 0.0,
        imageUrl: '',
        category: '',
        stockQuantity: 0,
        specifications: {},
        features: [],
        isWishlisted: false,
        reviews: [],
        createdAt: DateTime.now(),
        lastUpdated: DateTime.now(),
      );
    }
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    try {
      return Product(
        id: map['id']?.toString() ?? '',
        name: map['name']?.toString() ?? '',
        description: map['description']?.toString() ?? '',
        price: (map['price'] is num ? (map['price'] as num).toDouble() : 0.0),
        imageUrl: map['imageUrl']?.toString() ?? '',
        category: map['category']?.toString() ?? '',
        stockQuantity: (map['stockQuantity'] as num?)?.toInt() ?? 0,
        specifications: (map['specifications'] as Map<String, dynamic>?) ?? {},
        features: (map['features'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        isWishlisted: map['isWishlisted'] as bool? ?? false,
        reviews: (map['reviews'] as List<dynamic>?)
                ?.map(
                    (review) => Review.fromMap(review as Map<String, dynamic>))
                .toList() ??
            [],
        createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        lastUpdated:
            (map['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    } catch (e, stackTrace) {
      print('Error parsing product map: $e');
      print('Stack trace: $stackTrace');
      print('Product map: $map');
      rethrow;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'stockQuantity': stockQuantity,
      'specifications': specifications,
      'features': features,
      'isWishlisted': isWishlisted,
      'reviews': reviews.map((review) => review.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  // Helper getters
  String get formattedPrice => 'R${price.toStringAsFixed(2)}';
  bool get isInStock => stockQuantity > 0;
  String get stockStatus => isInStock ? 'In Stock' : 'Out of Stock';
  List<String> get colors =>
      (specifications['colors'] as List<dynamic>?)?.cast<String>() ?? [];
  String get material => specifications['material']?.toString() ?? '';
  String get dimensions => specifications['dimensions']?.toString() ?? '';
  String get thickness => specifications['thickness']?.toString() ?? '';
  String get weight => specifications['weight']?.toString() ?? '';

  // Copy with method for updating product
  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? category,
    int? stockQuantity,
    Map<String, dynamic>? specifications,
    List<String>? features,
    bool? isWishlisted,
    List<Review>? reviews,
    DateTime? createdAt,
    DateTime? lastUpdated,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      specifications: specifications ?? this.specifications,
      features: features ?? this.features,
      isWishlisted: isWishlisted ?? this.isWishlisted,
      reviews: reviews ?? this.reviews,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
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
    try {
      return Review(
        user: map['user']?.toString() ?? '',
        comment: map['comment']?.toString() ?? '',
        rating:
            (map['rating'] is num ? (map['rating'] as num).toDouble() : 0.0),
        timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    } catch (e) {
      print('Error parsing review: $e');
      return Review(
        user: '',
        comment: '',
        rating: 0,
        timestamp: DateTime.now(),
      );
    }
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
