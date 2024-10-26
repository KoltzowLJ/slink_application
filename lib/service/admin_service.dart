// lib/service/admin_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Check if user is admin
  Future<bool> isUserAdmin(String uid) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(uid).get();
      if (docSnapshot.exists) {
        final userData = docSnapshot.data() as Map<String, dynamic>;
        return userData['isAdmin'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }

  // Add product
  Future<String> addProduct(Product product) async {
    try {
      final docRef =
          await _firestore.collection('products').add(product.toMap());
      return docRef.id;
    } catch (e) {
      throw 'Failed to add product: $e';
    }
  }

  // Update product
  Future<void> updateProduct(Product product) async {
    try {
      await _firestore
          .collection('products')
          .doc(product.id)
          .update(product.toMap());
    } catch (e) {
      throw 'Failed to update product: $e';
    }
  }

  // Delete product
  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
    } catch (e) {
      throw 'Failed to delete product: $e';
    }
  }
}
