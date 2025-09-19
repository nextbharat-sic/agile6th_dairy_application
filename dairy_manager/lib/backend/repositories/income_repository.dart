import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dairy_manager/constants/constants.dart';

import '../../models/income_model.dart';

class IncomeRepository {
  final FirebaseFirestore firestore;

  IncomeRepository(this.firestore);

  Future<void> addIncome(
      String userId, String incomeId, IncomeModel model) async {
    await firestore
        .collection('users')
        .doc(userId)
        .collection('income')
        .doc(incomeId)
        .set(model.toMap());
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getIncomeForAnimalsInDateRange(
      String userId,
      DateTime startDateTime,
      DateTime endDateTime,
      List<AnimalType> animalTypes) async {
    // 'dateTime' is stored as ISO8601 string in Firestore via IncomeModel.toMap()
    final startIso = startDateTime.toIso8601String();
    final endIso = endDateTime.toIso8601String();

    final snapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('income')
        .where('dateTime', isGreaterThanOrEqualTo: startIso)
        .where('dateTime', isLessThanOrEqualTo: endIso)
        .where('animalType', whereIn: animalTypes.map((t) => t.key).toList())
        .get();

    return snapshot;
  }
}
