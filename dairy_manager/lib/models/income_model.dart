import 'package:cloud_firestore/cloud_firestore.dart';

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

  /// Create a model from a map, likely from a database record.
  factory IncomeModel.fromMap(Map<String, dynamic> map) {
    return IncomeModel(
      id: map['id'] as String,
      dateTime: map['dateTime'] is String
          ? DateTime.parse(map['dateTime'] as String)
          : (map['dateTime'] as Timestamp).toDate(),
      animalType: AnimalType.values.byName(map['animalType'] as String),
      session: SessionType.values.byName(map['session'] as String),
      liters: (map['liters'] as num).toDouble(),
      snf: (map['snf'] as num).toDouble(),
      fat: (map['fat'] as num).toDouble(),
      costPerLiter: (map['costPerLiter'] as num).toDouble(),
      totalIncome: (map['totalIncome'] as num).toDouble(),
      createdAt: map['createdAt'] is String
          ? DateTime.parse(map['createdAt'] as String)
          : map['createdAt'] != null 
              ? (map['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
      updatedAt: map['updatedAt'] is String
          ? DateTime.parse(map['updatedAt'] as String)
          : map['updatedAt'] != null 
              ? (map['updatedAt'] as Timestamp).toDate()
              : DateTime.now(),
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


class AddIncomeResponseModel {
  final String incomeId;
  final AnimalType animalType;
  final double costPerLiter;
  final double totalIncomeSession;
  final Map<AnimalType, double> todayIncomeList;

  AddIncomeResponseModel({
    required this.incomeId,
    required this.animalType,
    required this.costPerLiter,
    required this.totalIncomeSession,
    Map<AnimalType, double>? todayIncomeList,
  }) : todayIncomeList = todayIncomeList ?? _initializetodayIncomeList();

  static Map<AnimalType, double> _initializetodayIncomeList() {
    return Map.fromEntries(
      AnimalType.values.map((animal) => MapEntry(animal, 0.0)),
    );
  }

  double getIncomeFor(AnimalType animal) => todayIncomeList[animal] ?? 0.0;

  AddIncomeResponseModel updateIncomeFor(AnimalType animal, double income) {
    final updatedIncomes = Map<AnimalType, double>.from(todayIncomeList);
    updatedIncomes[animal] = income;

    return AddIncomeResponseModel(
      incomeId: incomeId,
      animalType: animalType,
      costPerLiter: costPerLiter,
      totalIncomeSession: totalIncomeSession,
      todayIncomeList: updatedIncomes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'incomeId': incomeId,
      'animalType': animalType.name,
      'costPerLiter': costPerLiter,
      'totalIncomeSession': totalIncomeSession,
      'todayIncomeList': todayIncomeList.map(
            (key, value) => MapEntry(key.name, value),
      ),
    };
  }
}

