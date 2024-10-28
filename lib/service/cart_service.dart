// lib/service/cart_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

// Service class for managing shopping cart operations
class CartService {
  // Firebase instance and collection name
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'carts';

  // Add a product to user's cart
  Future<void> addToCart(String userId, Product product) async {
    try {
      await _firestore.collection(_collection).doc(userId).set({
        'items': FieldValue.arrayUnion([product.toMap()])
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error adding to cart: $e');
      throw 'Failed to add item to cart';
    }
  }

  // Remove a product from user's cart
  Future<void> removeFromCart(String userId, Product product) async {
    try {
      await _firestore.collection(_collection).doc(userId).update({
        'items': FieldValue.arrayRemove([product.toMap()])
      });
    } catch (e) {
      print('Error removing from cart: $e');
      throw 'Failed to remove item from cart';
    }
  }

  // Get real-time stream of cart items for a user
  Stream<List<Product>> getCartItems(String userId) {
    return _firestore
        .collection(_collection)
        .doc(userId)
        .snapshots()
        .map(_convertSnapshotToProducts);
  }

  // Convert Firestore snapshot to List<Product>
  List<Product> _convertSnapshotToProducts(DocumentSnapshot snapshot) {
    if (!snapshot.exists) {
      return [];
    }

    try {
      final data = snapshot.data() as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>;
      return items.map((item) => Product.fromMap(item)).toList();
    } catch (e) {
      print('Error converting cart items: $e');
      return [];
    }
  }

  // Clear all items from user's cart
  Future<void> clearCart(String userId) async {
    try {
      await _firestore.collection(_collection).doc(userId).delete();
    } catch (e) {
      print('Error clearing cart: $e');
      throw 'Failed to clear cart';
    }
  }
}
