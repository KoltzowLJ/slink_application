// lib/service/cart_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collection = 'carts';

  // Add item to cart
  Future<void> addToCart(String userId, Product product) {
    return _firestore.collection(collection).doc(userId).set({
      'items': FieldValue.arrayUnion([product.toMap()])
    }, SetOptions(merge: true));
  }

  // Remove item from cart
  Future<void> removeFromCart(String userId, Product product) {
    return _firestore.collection(collection).doc(userId).update({
      'items': FieldValue.arrayRemove([product.toMap()])
    });
  }

  // Get cart items
  Stream<List<Product>> getCartItems(String userId) {
    return _firestore.collection(collection).doc(userId).snapshots().map(
      (snapshot) {
        if (!snapshot.exists) {
          return [];
        }
        final data = snapshot.data() as Map<String, dynamic>;
        final items = data['items'] as List<dynamic>;
        return items.map((item) => Product.fromMap(item)).toList();
      },
    );
  }

  // Clear cart
  Future<void> clearCart(String userId) {
    return _firestore.collection(collection).doc(userId).delete();
  }
}
