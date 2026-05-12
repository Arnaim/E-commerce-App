import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { buyer, seller }

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final UserRole role;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      role: map['role'] == 'seller' ? UserRole.seller : UserRole.buyer,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'role': role.name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
