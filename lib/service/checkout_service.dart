// lib/service/checkout_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class CheckoutService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createOrder(
      String userId, List<Product> products, double total) async {
    try {
      await _firestore.collection('orders').add({
        'userId': userId,
        'products': products.map((p) => p.toMap()).toList(),
        'total': total,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Clear the cart after successful order
      await _firestore.collection('carts').doc(userId).delete();
    } catch (e) {
      throw 'Failed to create order: $e';
    }
  }
}
