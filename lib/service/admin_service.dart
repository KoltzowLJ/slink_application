// lib/service/admin_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service class for handling admin-related operations
class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Dashboard Statistics
  Future<Map<String, int>> getDashboardStats() async {
    try {
      final stats = await Future.wait([
        _firestore.collection('products').count().get(),
        _firestore.collection('orders').count().get(),
        _firestore.collection('users').count().get(),
        _firestore.collection('bookings').count().get(),
      ]);

      return {
        'products': stats[0].count ?? 0,
        'orders': stats[1].count ?? 0,
        'users': stats[2].count ?? 0,
        'bookings': stats[3].count ?? 0,
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

  // User Management
  Future<bool> isUserAdmin(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data()?['isAdmin'] ?? false;
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }

  Future<void> updateUserAdminStatus(String userId, bool isAdmin) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .update({'isAdmin': isAdmin});
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  Future<void> disableUser(String uid) async {
    await _firestore.collection('users').doc(uid).update({'isActive': false});
  }

  Future<void> deleteUser(String uid) async {
    await _firestore.collection('users').doc(uid).delete();
  }

  // Product Management
  Future<String> addProduct(Map<String, dynamic> data) async {
    try {
      final docRef = await _firestore.collection('products').add(data);
      return docRef.id;
    } catch (e) {
      print('Error adding product: $e');
      throw 'Failed to add product';
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

  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
    } catch (e) {
      print('Error deleting product: $e');
      throw 'Failed to delete product';
    }
  }

  // Booking Management
  Future<void> addBooking(Map<String, dynamic> bookingData) async {
    await _firestore.collection('bookings').add(bookingData);
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _firestore
        .collection('bookings')
        .doc(bookingId)
        .update({'status': status});
  }

  Future<void> updateBookingNotes(String bookingId, String notes) async {
    await _firestore
        .collection('bookings')
        .doc(bookingId)
        .update({'notes': notes});
  }

  Future<void> deleteBooking(String bookingId) async {
    await _firestore.collection('bookings').doc(bookingId).delete();
  }

  // Order Management
  Future<void> updateOrderStatus(String orderId, String status) async {
    await _firestore
        .collection('orders')
        .doc(orderId)
        .update({'status': status});
  }

  // Data Streams
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
