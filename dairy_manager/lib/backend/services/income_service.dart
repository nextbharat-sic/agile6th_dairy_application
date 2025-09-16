import 'package:cloud_firestore/cloud_firestore.dart';
<<<<<<< HEAD
=======

>>>>>>> 1f0ca371040dcdf19f4ab6a3a76bf5a9ec7ad263
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
  Future<Map<String, dynamic>> addIncome({
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
    // 1. Generate a unique ID
    final incomeId = IdGenerator.generateIncomeId(dateTime, session, animalType);
    // 2. Determine actual current cost-per-liter
    //    Fetch from userRepo only if not provided
    final existingCost = currentCostPerLiter
        ?? await userRepo.getCostPerLiter(userId, animalType);
    // 3. If the new cost differs from existing, update user settings
    if (newCostPerLiter != existingCost) {
        await userRepo.updateCostPerLiter(userId, animalType, newCostPerLiter);
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

    // 6. Use the entity’s computed totalIncome for this session entry
    final totalIncomeSession = incomeEntity.totalIncome;

    // 7. Compute day total across all sessions of that animal
    final totalIncomeDay = await getTotalIncomeForDay(
      userId: userId,
      date: dateTime,
      animalType: animalType,
    );
    // 8. Return summary
    return {
      'incomeId': incomeId,
      'animalType': animalType.key,
      'costPerLiter': newCostPerLiter,
      'totalIncomeSession': totalIncomeSession,
      'totalIncomeDay': totalIncomeDay,
    };
  }

  /// Retrieves income records for the given animals within a given date range.
  Future<QuerySnapshot<Map<String, dynamic>>> getIncomeForAnimalInRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
    AnimalType animalType,
  ) async {
    return await incomeRepo.getIncomeForAnimalsInDateRange(
      userId,
      startDate,
      endDate,
      [animalType],
    );
  }

  /// Computes the total income for a user for a specific day and animal.
  Future<double> getTotalIncomeForDay({
    required String userId,
    required DateTime date,
    required AnimalType animalType,
  }) async {
    final dayStart = DateUtils.getStartOfDay(date);
    final dayEnd = DateUtils.getEndOfDay(date);
    final snapshot = await getIncomeForAnimalInRange(
      userId,
      dayStart,
      dayEnd,
      animalType,
    );
    double total = 0.0;
    for (final doc in snapshot.docs) {
      total += (doc.data()['totalIncome'] as num).toDouble();
    }
    return total;
  }
}
