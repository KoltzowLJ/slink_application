// lib/service/product_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collection = 'products';

  // Get all products
  Stream<List<Product>> getProducts() {
    return _firestore.collection(collection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromFirestore(doc);
      }).toList();
    });
  }

  // Get product by ID
  Future<Product?> getProductById(String id) async {
    final doc = await _firestore.collection(collection).doc(id).get();
    if (doc.exists) {
      return Product.fromFirestore(doc);
    }
    return null;
  }

  // Add product
  Future<void> addProduct(Product product) {
    return _firestore.collection(collection).add(product.toMap());
  }

  // Update product
  Future<void> updateProduct(Product product) {
    return _firestore
        .collection(collection)
        .doc(product.id)
        .update(product.toMap());
  }

  // Delete product
  Future<void> deleteProduct(String id) {
    return _firestore.collection(collection).doc(id).delete();
  }

  // Add review to product
  Future<void> addReview(String productId, Review review) {
    return _firestore.collection(collection).doc(productId).update({
      'reviews': FieldValue.arrayUnion([review.toMap()])
    });
  }
}
