import '../backend/entities/user_entity.dart';

/// Presentation/data‐transfer model class.
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phoneNumber;
  final String farmLocation;
  final double costPerLiterCow;
  final double costPerLiterBuffalo;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.farmLocation,
    required this.costPerLiterCow,
    required this.costPerLiterBuffalo,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a model from an entity
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      name: entity.name,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      farmLocation: entity.farmLocation,
      costPerLiterCow: entity.costPerLiterCow,
      costPerLiterBuffalo: entity.costPerLiterBuffalo,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Create a model from Firestore data
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      farmLocation: map['farmLocation'] ?? '',
      costPerLiterCow: (map['costPerLiterCow'] as num?)?.toDouble() ?? 50.0,
      costPerLiterBuffalo: (map['costPerLiterBuffalo'] as num?)?.toDouble() ?? 55.0,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'name': name,
    'email': email,
    'phoneNumber': phoneNumber,
    'farmLocation': farmLocation,
    'costPerLiterCow': costPerLiterCow,
    'costPerLiterBuffalo': costPerLiterBuffalo,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  /// Create a copy with updated fields
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? phoneNumber,
    String? farmLocation,
    double? costPerLiterCow,
    double? costPerLiterBuffalo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      farmLocation: farmLocation ?? this.farmLocation,
      costPerLiterCow: costPerLiterCow ?? this.costPerLiterCow,
      costPerLiterBuffalo: costPerLiterBuffalo ?? this.costPerLiterBuffalo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

