// lib/models/user_model.dart

class UserModel {
  final String uid;
  final String email;
  final String name;
  final bool isAdmin;
  final int loyaltyPoints;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.isAdmin = false,
    this.loyaltyPoints = 0,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      isAdmin: map['isAdmin'] ?? false,
      loyaltyPoints: map['loyaltyPoints'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'isAdmin': isAdmin,
      'loyaltyPoints': loyaltyPoints,
    };
  }

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
}
