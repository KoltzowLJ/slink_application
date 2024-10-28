// lib/models/booking_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final String userId;
  final String userName;
  final String serviceType;
  final DateTime dateTime;
  final double duration;
  final double price;
  final String status;
  final String trainerName;
  final String notes;
  final DateTime createdAt;
  final DateTime lastUpdated;

  Booking({
    required this.id,
    required this.userId,
    required this.userName,
    required this.serviceType,
    required this.dateTime,
    required this.duration,
    required this.price,
    this.status = 'pending',
    this.trainerName = '',
    this.notes = '',
    DateTime? createdAt,
    DateTime? lastUpdated,
  })  : createdAt = createdAt ?? DateTime.now(),
        lastUpdated = lastUpdated ?? DateTime.now();

  factory Booking.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    double convertToDouble(dynamic value) {
      if (value is int) return value.toDouble();
      if (value is double) return value;
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return Booking(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      serviceType: data['serviceType'] ?? '',
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      duration: convertToDouble(data['duration']),
      price: convertToDouble(data['price']),
      status: data['status'] ?? 'pending',
      trainerName: data['trainerName'] ?? '',
      notes: data['notes'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'serviceType': serviceType,
      'dateTime': Timestamp.fromDate(dateTime),
      'duration': duration,
      'price': price,
      'status': status,
      'trainerName': trainerName,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  Booking copyWith({
    String? id,
    String? userId,
    String? userName,
    String? serviceType,
    DateTime? dateTime,
    double? duration,
    double? price,
    String? status,
    String? trainerName,
    String? notes,
    DateTime? createdAt,
    DateTime? lastUpdated,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      serviceType: serviceType ?? this.serviceType,
      dateTime: dateTime ?? this.dateTime,
      duration: duration ?? this.duration,
      price: price ?? this.price,
      status: status ?? this.status,
      trainerName: trainerName ?? this.trainerName,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
