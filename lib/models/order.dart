// lib/models/order.dart

// A comprehensive model for handling e-commerce orders in the application.
// Used for managing orders and syncing with Firestore database.

import 'package:cloud_firestore/cloud_firestore.dart';

// Represents a single product item in an order
class OrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price;
  final String imageUrl;
  final String category;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.imageUrl,
    required this.category,
  });

  // Convert to map for storage
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
    };
  }

  // Create from stored map
  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      quantity: map['quantity']?.toInt() ?? 0,
      price: (map['price'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? '',
    );
  }
}

// Handles delivery address information
class ShippingAddress {
  final String streetAddress;
  final String city;
  final String province;
  final String postalCode;
  final String country;
  final String contactNumber;

  ShippingAddress({
    required this.streetAddress,
    required this.city,
    required this.province,
    required this.postalCode,
    required this.country,
    required this.contactNumber,
  });

  // Convert to map for storage
  Map<String, dynamic> toMap() {
    return {
      'streetAddress': streetAddress,
      'city': city,
      'province': province,
      'postalCode': postalCode,
      'country': country,
      'contactNumber': contactNumber,
    };
  }

  // Create from stored map
  factory ShippingAddress.fromMap(Map<String, dynamic> map) {
    return ShippingAddress(
      streetAddress: map['streetAddress'] ?? '',
      city: map['city'] ?? '',
      province: map['province'] ?? '',
      postalCode: map['postalCode'] ?? '',
      country: map['country'] ?? '',
      contactNumber: map['contactNumber'] ?? '',
    );
  }
}

// Main order class containing all order information
class OrderModel {
  // Order identification
  final String id;
  final String userId;
  final String userName;

  // Order contents and costs
  final List<OrderItem> items;
  final double subtotal;
  final double tax;
  final double total;

  // Order status
  final String status;
  final String paymentStatus;
  final String paymentMethod;

  // Shipping details
  final String shippingAddress;
  final String orderNotes;
  final String trackingNumber;
  final DateTime? estimatedDeliveryDate;

  // Metadata
  final DateTime createdAt;
  final DateTime lastUpdated;
  final String cancelReason;

  OrderModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.shippingAddress,
    this.orderNotes = '',
    required this.createdAt,
    required this.lastUpdated,
    this.estimatedDeliveryDate,
    this.trackingNumber = '',
    this.cancelReason = '',
  });

  // Convert to Firestore format
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'total': total,
      'status': status,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'shippingAddress': shippingAddress,
      'orderNotes': orderNotes,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      if (estimatedDeliveryDate != null)
        'estimatedDeliveryDate': Timestamp.fromDate(estimatedDeliveryDate!),
      'trackingNumber': trackingNumber,
      'cancelReason': cancelReason,
    };
  }

  // Create from Firestore document
  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    List<OrderItem> orderItems = [];
    if (data['items'] != null) {
      orderItems = (data['items'] as List)
          .map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
          .toList();
    }

    return OrderModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      items: orderItems,
      subtotal: (data['subtotal'] ?? 0.0).toDouble(),
      tax: (data['tax'] ?? 0.0).toDouble(),
      total: (data['total'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'pending',
      paymentStatus: data['paymentStatus'] ?? 'pending',
      paymentMethod: data['paymentMethod'] ?? '',
      shippingAddress: data['shippingAddress'] ?? '',
      orderNotes: data['orderNotes'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
      estimatedDeliveryDate: data['estimatedDeliveryDate'] != null
          ? (data['estimatedDeliveryDate'] as Timestamp).toDate()
          : null,
      trackingNumber: data['trackingNumber'] ?? '',
      cancelReason: data['cancelReason'] ?? '',
    );
  }

  // Create a copy with updated fields
  OrderModel copyWith({
    String? id,
    String? userId,
    String? userName,
    List<OrderItem>? items,
    double? subtotal,
    double? tax,
    double? total,
    String? status,
    String? paymentStatus,
    String? paymentMethod,
    String? shippingAddress,
    String? orderNotes,
    DateTime? createdAt,
    DateTime? lastUpdated,
    DateTime? estimatedDeliveryDate,
    String? trackingNumber,
    String? cancelReason,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      orderNotes: orderNotes ?? this.orderNotes,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      estimatedDeliveryDate:
          estimatedDeliveryDate ?? this.estimatedDeliveryDate,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      cancelReason: cancelReason ?? this.cancelReason,
    );
  }
}
