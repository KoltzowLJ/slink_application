// lib/service/admin_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, int>> getDashboardStats() async {
    try {
      final products = await _firestore.collection('products').count().get();
      final orders = await _firestore.collection('orders').count().get();
      final users = await _firestore.collection('users').count().get();
      final bookings = await _firestore.collection('bookings').count().get();

      return {
        'products': products.count ?? 0, // Add null check with default value
        'orders': orders.count ?? 0,
        'users': users.count ?? 0,
        'bookings': bookings.count ?? 0,
      };
    } catch (e) {
      print('Error getting dashboard stats: $e');
      return {
        'products': 0,
        'orders': 0,
        'users': 0,
        'bookings': 0,
      };
    }
  }

  // Add method to check if user is admin
  Future<bool> isUserAdmin(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data()?['isAdmin'] ?? false;
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }

  // Add other admin-related methods here
  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
    } catch (e) {
      print('Error deleting product: $e');
      throw 'Failed to delete product';
    }
  }

  Future<void> updateProduct(
      String productId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('products').doc(productId).update(data);
    } catch (e) {
      print('Error updating product: $e');
      throw 'Failed to update product';
    }
  }

  Future<String> addProduct(Map<String, dynamic> data) async {
    try {
      final docRef = await _firestore.collection('products').add(data);
      return docRef.id;
    } catch (e) {
      print('Error adding product: $e');
      throw 'Failed to add product';
    }
  }

  Stream<QuerySnapshot> getProducts() {
    return _firestore.collection('products').snapshots();
  }

  Stream<QuerySnapshot> getUsers() {
    return _firestore.collection('users').snapshots();
  }

  Stream<QuerySnapshot> getOrders() {
    return _firestore.collection('orders').snapshots();
  }

  Stream<QuerySnapshot> getBookings() {
    return _firestore.collection('bookings').snapshots();
  }
}
