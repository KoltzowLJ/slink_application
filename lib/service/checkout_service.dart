// lib/service/checkout_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';

// Service class for handling checkout and order creation
class CheckoutService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const double _taxRate = 0.15;

  // Create a new order
  Future<void> createOrder(
    String userId,
    List<Product> products,
    double total, {
    required String shippingAddress,
    required String paymentMethod,
    required String orderNotes,
    required String phoneNumber,
  }) async {
    try {
      // Validate stock before proceeding
      await validateStock(products);

      // Create order data
      final orderData = await _prepareOrderData(
        userId: userId,
        products: products,
        shippingAddress: shippingAddress,
        paymentMethod: paymentMethod,
        orderNotes: orderNotes,
        phoneNumber: phoneNumber,
      );

      // Create order in Firestore
      await _firestore.collection('orders').add(orderData);

      // Update product stock
      await _updateProductStock(products);

      // Clear user's cart
      await _clearUserCart(userId);
    } catch (e) {
      print('Error creating order: $e');
      throw 'Failed to create order: $e';
    }
  }

  // Prepare order data for Firestore
  Future<Map<String, dynamic>> _prepareOrderData({
    required String userId,
    required List<Product> products,
    required String shippingAddress,
    required String paymentMethod,
    required String orderNotes,
    required String phoneNumber,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? 'Unknown';

    // Calculate totals
    final orderTotals = _calculateOrderTotals(products);
    final orderItems = _prepareOrderItems(products);

    return {
      'userId': userId,
      'userName': userName,
      'items': orderItems,
      'subtotal': orderTotals['subtotal'],
      'tax': orderTotals['tax'],
      'total': orderTotals['total'],
      'status': 'pending',
      'paymentStatus': 'pending',
      'paymentMethod': paymentMethod,
      'shippingAddress': shippingAddress,
      'orderNotes': orderNotes,
      'phoneNumber': phoneNumber,
      'createdAt': FieldValue.serverTimestamp(),
      'lastUpdated': FieldValue.serverTimestamp(),
      'estimatedDeliveryDate': null,
      'trackingNumber': '',
      'cancelReason': '',
    };
  }

  // Calculate order totals
  Map<String, double> _calculateOrderTotals(List<Product> products) {
    double subtotal = products.fold(0, (sum, product) => sum + product.price);
    double tax = subtotal * _taxRate;
    double total = subtotal + tax;

    return {
      'subtotal': subtotal,
      'tax': tax,
      'total': total,
    };
  }

  // Prepare order items for Firestore
  List<Map<String, dynamic>> _prepareOrderItems(List<Product> products) {
    return products.map((product) {
      return {
        'productId': product.id,
        'productName': product.name,
        'quantity': 1,
        'price': product.price,
        'imageUrl': product.imageUrl,
        'category': product.category,
      };
    }).toList();
  }

  // Update product stock quantities
  Future<void> _updateProductStock(List<Product> products) async {
    for (var product in products) {
      await _firestore.collection('products').doc(product.id).update({
        'stockQuantity': FieldValue.increment(-1),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }
  }

  // Clear user's cart after successful order
  Future<void> _clearUserCart(String userId) async {
    await _firestore.collection('carts').doc(userId).delete();
  }

  // Validate product stock availability
  Future<bool> validateStock(List<Product> products) async {
    for (var product in products) {
      try {
        final productDoc =
            await _firestore.collection('products').doc(product.id).get();

        if (!productDoc.exists) {
          throw 'Product ${product.name} (ID: ${product.id}) no longer exists';
        }

        final productData = productDoc.data() as Map<String, dynamic>;
        final currentStock = productData['stockQuantity'] ?? 0;

        if (currentStock < 1) {
          throw 'Product ${product.name} is out of stock';
        }
      } catch (e) {
        print('Error validating stock for product ${product.id}: $e');
        rethrow;
      }
    }
    return true;
  }
}
