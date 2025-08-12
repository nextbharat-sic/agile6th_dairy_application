import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dairy_manager/constants/constants.dart';

import '../../models/income_model.dart';

class IncomeRepository {
  final FirebaseFirestore firestore;

  IncomeRepository(this.firestore);

  Future<void> addIncome(String userId, String incomeId, IncomeModel model) async {
    await firestore.collection('users').doc(userId)
        .collection('income').doc(incomeId)
        .set(model.toMap());
  }

  Future<double> getTotalIncome(String userId, DateTime startDateTime, DateTime endDateTime, AnimalType animalType) async {
    double totalIncome = 0;
    final snapshot = await firestore.collection('users').doc(userId)
        .collection('income')
        .where('dateTime', isGreaterThanOrEqualTo: startDateTime)
        .where('dateTime', isLessThanOrEqualTo: endDateTime)
        .where('animalType', isEqualTo: animalType.key)
        .get();

    for (var doc in snapshot.docs) {
      totalIncome += (doc.data()['totalIncome'] as num).toDouble();
    }
    return totalIncome;
  }
}
