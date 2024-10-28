// lib/models/user_model.dart

// A model class representing a user in the application.

class UserModel {
  // User identification
  final String uid;
  final String email;
  final String name;

  // User privileges and rewards
  final bool isAdmin;
  final int loyaltyPoints;

  /// Creates a new UserModel instance
  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.isAdmin = false,
    this.loyaltyPoints = 0,
  });

  /// Creates a UserModel from a data map
  /// Used when retrieving user data from storage
  /// Provides default values if fields are missing
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      isAdmin: map['isAdmin'] ?? false,
      loyaltyPoints: map['loyaltyPoints'] ?? 0,
    );
  }

  // Converts UserModel to a data map
  // Used when storing user data
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'isAdmin': isAdmin,
      'loyaltyPoints': loyaltyPoints,
    };
  }

  // Creates a copy of UserModel with optional field updates
  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    bool? isAdmin,
    int? loyaltyPoints,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      isAdmin: isAdmin ?? this.isAdmin,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, name: $name, isAdmin: $isAdmin, loyaltyPoints: $loyaltyPoints)';
  }
}
