import '../../utils/validators.dart';

/// Domain/entity class responsible for validation and business logic.
class UserEntity {
  final String uid;
  final String name;
  final String email;
  final String phoneNumber;
  final String farmLocation;
  final double costPerLiterCow;
  final double costPerLiterBuffalo;
  final int age;
  final int cattleOwned;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserEntity({
    required this.uid,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.farmLocation,
    required this.costPerLiterCow,
    required this.costPerLiterBuffalo,
    this.age = 0,
    this.cattleOwned = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now() {
    
    // Validate cost values are non-negative
    Validator.validateNonNegativeNumber('costPerLiterCow', costPerLiterCow);
    Validator.validateNonNegativeNumber('costPerLiterBuffalo', costPerLiterBuffalo);
  }
}
