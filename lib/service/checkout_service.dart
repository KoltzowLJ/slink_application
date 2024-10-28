// lib/service/checkout_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';

class CheckoutService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      await validateStock(products);

      // Get user information
      final user = FirebaseAuth.instance.currentUser;
      final userName = user?.displayName ?? 'Unknown';

      // Calculate totals
      double subtotal = products.fold(0,
          (sum, product) => sum + (product.price * 1)); // Assuming quantity 1
      double tax = subtotal * 0.15; // 15% tax
      double finalTotal = subtotal + tax;

      // Convert products to order items format
      List<Map<String, dynamic>> orderItems = products.map((product) {
        return {
          'productId': product.id,
          'productName': product.name,
          'quantity': 1, // You might want to add quantity handling
          'price': product.price,
          'imageUrl': product.imageUrl,
          'category': product.category,
        };
      }).toList();

      // Create the order document
      final orderData = {
        'userId': userId,
        'userName': userName,
        'items': orderItems,
        'subtotal': subtotal,
        'tax': tax,
        'total': finalTotal,
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

      // Create the order
      await _firestore.collection('orders').add(orderData);

      // Update stock quantities
      for (var product in products) {
        await _firestore.collection('products').doc(product.id).update({
          'stockQuantity': FieldValue.increment(-1), // Decrease by 1
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }

      // Clear the cart after successful order
      await _firestore.collection('carts').doc(userId).delete();
    } catch (e) {
      print('Error creating order: $e');
      throw 'Failed to create order: $e';
    }
  }

  // Helper method to validate stock before order creation
  Future<bool> validateStock(List<Product> products) async {
    for (var product in products) {
      try {
        print('Validating product: ${product.id}'); // Debug log

        DocumentSnapshot productDoc =
            await _firestore.collection('products').doc(product.id).get();

        print('Product exists: ${productDoc.exists}'); // Debug log

        if (!productDoc.exists) {
          throw 'Product ${product.name} (ID: ${product.id}) no longer exists';
        }

        Map<String, dynamic> productData =
            productDoc.data() as Map<String, dynamic>;
        print('Product data: $productData'); // Debug log

        int currentStock = productData['stockQuantity'] ?? 0;
        print('Current stock: $currentStock'); // Debug log

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
