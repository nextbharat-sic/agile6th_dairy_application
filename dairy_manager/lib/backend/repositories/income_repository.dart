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

  /// Fetches income records for a user within a specific date range,
  /// with optional filtering by a single animal type and session type.
  Future<QuerySnapshot<Map<String, dynamic>>> getIncomeForAnimalsInDateRange(
    String userId,
    DateTime startDateTime,
    DateTime endDateTime, {
    AnimalType? animalType,
    SessionType? sessionType,
  }) async {
    // 1. Start with the base query pointing to the collection
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('income');

    // 2. Conditionally add filters if the parameters are not null
    if (animalType != null) {
      query = query.where('animalType', isEqualTo: animalType.key);
    }

    if (sessionType != null) {
      query = query.where('session', isEqualTo: sessionType.key);
    }

    // 3. Add the mandatory date range and ordering
    // Note: The first orderBy must match the field in your range filter ('>', '<')
    query = query
        .where('dateTime',
            isGreaterThanOrEqualTo: startDateTime.toIso8601String())
        .where('dateTime', isLessThanOrEqualTo: endDateTime.toIso8601String())
        .orderBy('dateTime', descending: true);

    // 4. Execute the fully constructed query
    final snapshot = await query.get();
    for (final doc in snapshot.docs) {
      print(doc.data());
    }
    return snapshot;
  }
}
