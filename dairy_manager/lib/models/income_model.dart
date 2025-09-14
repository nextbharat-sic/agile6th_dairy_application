import '../backend/entities/income_entity.dart';
import '../constants/constants.dart';

/// Presentation/data‐transfer model class.
class IncomeModel {
  final String id;
  final DateTime dateTime;
  final AnimalType animalType;
  final SessionType session;
  final double liters;
  final double snf;
  final double fat;
  final double costPerLiter;
  final double totalIncome;
  final DateTime createdAt;
  final DateTime updatedAt;

  IncomeModel({
    required this.id,
    required this.dateTime,
    required this.animalType,
    required this.session,
    required this.liters,
    required this.snf,
    required this.fat,
    required this.costPerLiter,
    required this.totalIncome,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a model from an entity, reusing entity’s computed totalIncome.
  factory IncomeModel.fromEntity(IncomeEntity entity) {
    return IncomeModel(
      id: entity.id,
      dateTime: entity.dateTime,
      animalType: AnimalType.values.byName(entity.animalType),
      session: SessionType.values.byName(entity.session),
      liters: entity.liters,
      snf: entity.snf,
      fat: entity.fat,
      costPerLiter: entity.costPerLiter,
      totalIncome: entity.totalIncome,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'dateTime': dateTime.toIso8601String(),
    'animalType': animalType.key,
    'session': session.key,
    'liters': liters,
    'snf': snf,
    'fat': fat,
    'costPerLiter': costPerLiter,
    'totalIncome': totalIncome,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}
