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
}

class Review {
  final String user;
  final String comment;
  final double rating;

  Review({
    required this.user,
    required this.comment,
    required this.rating,
  });
}
