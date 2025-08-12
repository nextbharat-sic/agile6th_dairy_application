import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dairy_manager/constants/constants.dart';

class UserRepository {
  final FirebaseFirestore firestore;

  UserRepository(this.firestore);

  /// Retrieves the current cost-per-liter for the given animal.
  /// Returns 0.0 if no value is set.
  Future<double> getCostPerLiter(String userId, AnimalType animalType) async {
    final docRef = firestore.collection('users').doc(userId);
    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      return 0.0;
    }

    final data = snapshot.data()!;
    switch (animalType) {
      case AnimalType.cow:
        return (data['costPerLiterCow'] as num?)?.toDouble() ?? 0.0;
      case AnimalType.buffalo:
        return (data['costPerLiterBuffalo'] as num?)?.toDouble() ?? 0.0;
    }
  }

  /// Updates the user's cost-per-liter for the given animal.
  Future<void> updateCostPerLiter(
      String userId, AnimalType animalType, double newCost) {
    String fieldName;
    switch (animalType) {
      case AnimalType.cow:
        fieldName = 'costPerLiterCow';
        break;
      case AnimalType.buffalo:
        fieldName = 'costPerLiterBuffalo';
        break;
    }
    return firestore
        .collection('users')
        .doc(userId)
        .update({fieldName: newCost});
  }
}
