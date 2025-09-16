import '../../constants/constants.dart';
import '../../utils/validators.dart';

/// Domain/entity class responsible for validation and business logic.
class IncomeEntity {
  final String id;
  final DateTime dateTime;
  final String animalType;
  final String session;
  final double liters;
  final double snf;
  final double fat;
  final double costPerLiter;
  final double totalIncome;
  final DateTime createdAt;
  final DateTime updatedAt;

  IncomeEntity({
    required this.id,
    required this.dateTime,
    required this.animalType,
    required this.session,
    required this.liters,
    required this.snf,
    required this.fat,
    required this.costPerLiter,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        totalIncome = _calculateTotalIncome(liters, costPerLiter) {
    // --- VALIDATE ENUM STRINGS ---
    final validAnimalTypes = AnimalType.values.map((e) => e.key).toList();
    if (!validAnimalTypes.contains(animalType)) {
      throw ArgumentError(
        'Invalid animal type "$animalType". Must be one of $validAnimalTypes.',
      );
    }

    final validSessions = SessionType.values.map((e) => e.key).toList();
    if (!validSessions.contains(session)) {
      throw ArgumentError(
        'Invalid session "$session". Must be one of $validSessions.',
      );
    }

    // --- VALIDATE NUMERICAL INPUTS ---
    Validator.validatePositiveNumber('liters', liters);
    Validator.validatePositiveNumber('costPerLiter', costPerLiter);
    Validator.validateNonNegativeNumber('snf', snf);
    Validator.validateNonNegativeNumber('fat', fat);
  }

  /// Centralized business logic: calculate total income.
  static double _calculateTotalIncome(double liters, double costPerLiter) {
    return liters * costPerLiter;
  }
}
