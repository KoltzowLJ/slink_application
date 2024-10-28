// lib/service/product_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

// Service class for managing product-related operations
class ProductService {
  // Firebase instance and collection name
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'products';

  // Get a stream of all products
  Stream<List<Product>> getProducts() {
    try {
      return _firestore
          .collection(_collection)
          .snapshots()
          .map(_convertSnapshotToProducts);
    } catch (e) {
      print('Error getting products stream: $e');
      rethrow;
    }
  }

  // Convert Firebase snapshot to List<Product>
  List<Product> _convertSnapshotToProducts(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
  }

  // Get a single product by ID
  Future<Product?> getProductById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      return doc.exists ? Product.fromFirestore(doc) : null;
    } catch (e) {
      print('Error getting product by ID: $e');
      rethrow;
    }
  }

  // Add a new product to the database
  Future<void> addProduct(Product product) async {
    try {
      await _firestore.collection(_collection).add(product.toMap());
    } catch (e) {
      print('Error adding product: $e');
      throw 'Failed to add product';
    }
  }

  // Update an existing product
  Future<void> updateProduct(Product product) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(product.id)
          .update(product.toMap());
    } catch (e) {
      print('Error updating product: $e');
      throw 'Failed to update product';
    }
  }

  // Delete a product from the database
  Future<void> deleteProduct(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      print('Error deleting product: $e');
      throw 'Failed to delete product';
    }
  }

  // Add a review to a product
  Future<void> addReview(String productId, Review review) async {
    try {
      await _firestore.collection(_collection).doc(productId).update({
        'reviews': FieldValue.arrayUnion([review.toMap()])
      });
    } catch (e) {
      print('Error adding review: $e');
      throw 'Failed to add review';
    }
  }

  // Get products by category
  Stream<List<Product>> getProductsByCategory(String category) {
    try {
      return _firestore
          .collection(_collection)
          .where('category', isEqualTo: category)
          .snapshots()
          .map(_convertSnapshotToProducts);
    } catch (e) {
      print('Error getting products by category: $e');
      rethrow;
    }
  }

  // Search products by name
  Future<List<Product>> searchProducts(String query) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      return querySnapshot.docs
          .map((doc) => Product.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error searching products: $e');
      return [];
    }
  }
}
