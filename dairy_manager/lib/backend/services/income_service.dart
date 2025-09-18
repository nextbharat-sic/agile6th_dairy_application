import 'package:cloud_firestore/cloud_firestore.dart';

import '../../constants/constants.dart';
import '../../models/income_model.dart';
import '../../utils/date_utils.dart';
import '../../utils/id_generator.dart';
import '../entities/income_entity.dart';
import '../repositories/income_repository.dart';
import '../repositories/user_repository.dart';

class IncomeService {
  final IncomeRepository incomeRepo;
  final UserRepository userRepo;

  IncomeService({
    required this.incomeRepo,
    required this.userRepo,
  });

  /// Adds a new income record, updates the user’s cost-per-liter if needed,
  /// and returns the entry’s income plus the day total.
  Future<AddIncomeResponseModel> addIncome({
    required String userId,
    required DateTime dateTime,
    required AnimalType animalType,
    required SessionType session,
    required double liters,
    required double snf,
    required double fat,
    required double newCostPerLiter,
    double? currentCostPerLiter,
  }) async {
    final incomeModel = await saveIncomeEntry(
        userId: userId,
        dateTime: dateTime,
        animalType: animalType,
        session: session,
        liters: liters,
        snf: snf,
        fat: fat,
        newCostPerLiter: newCostPerLiter,
        currentCostPerLiter: currentCostPerLiter);

    // 6. Use the entity’s computed totalIncome for this session entry
    final totalIncomeSession = incomeModel.totalIncome;

    // 7. Compute day total across all sessions of that animal
    final todayIncomeList = await getTotalIncomeForDay(
      userId: userId,
      date: dateTime,
      animalTypes: [AnimalType.cow, AnimalType.buffalo],
    );

    // 8. Return summary
    return AddIncomeResponseModel(
        incomeId: incomeModel.id,
        animalType: animalType,
        costPerLiter: newCostPerLiter,
        totalIncomeSession: totalIncomeSession,
        todayIncomeList: todayIncomeList);
  }

  /// Creates or Updates an income entry.
  Future<IncomeModel> saveIncomeEntry({
    required String userId,
    required DateTime dateTime,
    required AnimalType animalType,
    required SessionType session,
    required double liters,
    required double snf,
    required double fat,
    required double newCostPerLiter,
    double? currentCostPerLiter,
    String? existingIncomeId,
  }) async {
    final incomeId = existingIncomeId ??
        IdGenerator.generateIncomeId(dateTime, session, animalType);

    // 1. If we are updating an existing entry, skip cost update.
    if (existingIncomeId == null) {
      // 2. Determine actual current cost-per-liter
      //    Fetch from userRepo only if not provided
      final existingCost = currentCostPerLiter ??
          await userRepo.getCostPerLiter(userId, animalType);

      // 3. If the new cost differs from existing, update user settings
      if (newCostPerLiter != existingCost) {
        await userRepo.updateCostPerLiter(userId, animalType, newCostPerLiter);
      }
    }
    // 4. Create the entity (validation + computes totalIncome)
    final incomeEntity = IncomeEntity(
      id: incomeId,
      dateTime: dateTime,
      animalType: animalType.key,
      session: session.key,
      liters: liters,
      snf: snf,
      fat: fat,
      costPerLiter: newCostPerLiter,
    );

    // 5. Map entity to model and persist
    final incomeModel = IncomeModel.fromEntity(incomeEntity);
    await incomeRepo.addIncome(userId, incomeId, incomeModel);

    return incomeModel;
  }

  /// Retrieves income records for the given animals within a given date range.
  Future<QuerySnapshot<Map<String, dynamic>>> getIncomeForAnimalsInRange(
      String userId,
      DateTime startDate,
      DateTime endDate,
      List<AnimalType> animalTypes) async {
    return await incomeRepo.getIncomeForAnimalsInDateRange(
        userId, startDate, endDate);
  }

  /// Computes the total income for a user for a specific day, broken down by animal type.
  Future<Map<AnimalType, double>> getTotalIncomeForDay({
    required String userId,
    required DateTime date,
    required List<AnimalType> animalTypes,
  }) async {
    final dayStart = DateUtils.getStartOfDay(date);
    final dayEnd = DateUtils.getEndOfDay(date);
    final Map<AnimalType, double> totalIncomeByAnimal = {};

    // Initialize total income for each animal type to 0.0
    for (final animalType in animalTypes) {
      totalIncomeByAnimal[animalType] = 0.0;
    }

    final snapshot = await getIncomeForAnimalsInRange(
      userId,
      dayStart,
      dayEnd,
      animalTypes,
    );
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final animalTypeKey = data['animalType'] as String;
      final animalType =
          AnimalType.values.firstWhere((e) => e.key == animalTypeKey);
      totalIncomeByAnimal[animalType] =
          (totalIncomeByAnimal[animalType] ?? 0.0) +
              (data['totalIncome'] as num).toDouble();
    }
    return totalIncomeByAnimal;
  }

  Future<List<IncomeModel>> getIncomeEntriesForDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    required AnimalType animalType,
    required SessionType sessionType,
  }) async {
    final normalizedStartDate = DateUtils.getStartOfDay(startDate);
    final normalizedEndDate = DateUtils.getEndOfDay(endDate);

    // Step 1: Fetch all entries for the specified criteria
    final snapshot = await incomeRepo.getIncomeForAnimalsInDateRange(
      userId,
      normalizedStartDate,
      normalizedEndDate,
      animalType: animalType,
      sessionType: sessionType,
    );

    // Convert snapshot to List<IncomeModel>
    final fetchedEntries =
        snapshot.docs.map((doc) => IncomeModel.fromMap(doc.data())).toList();

    // Step 2: Call function to create skeleton list with fetched data
    return _createIncomeSkeletonList(
      normalizedStartDate,
      normalizedEndDate,
      sessionType,
      animalType,
      fetchedEntries,
    );
  }

  List<IncomeModel> _createIncomeSkeletonList(
    DateTime start,
    DateTime end,
    SessionType sessionType,
    AnimalType animalType,
    List<IncomeModel> fetchedEntries,
  ) {
    // Create a map for quick lookup of existing entries by date
    final existingEntriesMap = {
      for (var entry in fetchedEntries)
        DateUtils.generateGroupKeyForDate(entry.dateTime, GroupByFrequency.day):
            entry
    };

    final skeleton = <IncomeModel>[
      for (var cursor = start;
          !cursor.isAfter(end);
          cursor =
              DateUtils.advanceDateToNextGroup(cursor, GroupByFrequency.day))
        existingEntriesMap[DateUtils.generateGroupKeyForDate(
                cursor, GroupByFrequency.day)] ??
            _createDummyIncomeModel(
              date: cursor,
              animalType: animalType,
              sessionType: sessionType,
            )
    ];

    return skeleton;
  }

  IncomeModel _createDummyIncomeModel({
    required DateTime date,
    required AnimalType animalType,
    required SessionType sessionType,
  }) {
    return IncomeModel(
      id: '--', // Placeholder ID
      dateTime: date,
      animalType: animalType,
      session: sessionType,
      liters: double.nan, // handle this in UI
      snf: double.nan, // handle this in UI
      fat: double.nan, // handle this in UI
      costPerLiter: double.nan, // handle this in UI
      totalIncome: double.nan, // handle this in UI
      createdAt: date,
      updatedAt: date,
    );
  }
}
