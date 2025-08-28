import 'dart:developer' as dev;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dairy_manager/constants/constants.dart';

import '../../models/user_model.dart';
import '../entities/user_entity.dart';

class UserRepository {
  final FirebaseFirestore firestore;
  final _auth = FirebaseAuth.instance;

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

  /// Upserts user data to Firestore using Entity-Model pattern.
  /// Creates a new user document if one doesn't exist, otherwise updates existing document.
  Future<void> upsertUserOld({
    String? name,
    String? phoneNumber,
    String? farmLocation,
    double? costCow,
    double? costBuffalo,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('upsertUser: no signed-in user');

    final docRef = firestore.collection('users').doc(user.uid);

    await firestore.runTransaction((tx) async {
      final snap = await tx.get(docRef);

      if (!snap.exists) {
        // Create new user entity with validation
        final entity = UserEntity(
          uid: user.uid,
          name: name ?? user.displayName ?? '',
          email: user.email ?? '',
          phoneNumber: phoneNumber ?? '',
          farmLocation: farmLocation ?? '',
          costPerLiterCow: costCow ?? 50.0,
          costPerLiterBuffalo: costBuffalo ?? 55.0,
        );

        // Convert to model for storage
        final model = UserModel.fromEntity(entity);
        tx.set(docRef, model.toMap());
        dev.log('Created user doc for ${user.uid}', name: 'UserRepository');
      } else {
        // Get existing user data
        final existingModel = UserModel.fromMap(snap.data() ?? const <String, dynamic>{});

        // Create updated entity with new values (fallback to existing if not provided)
        final updatedEntity = UserEntity(
          uid: user.uid,
          name: name ?? existingModel.name,
          email: user.email ?? existingModel.email,
          phoneNumber: phoneNumber ?? existingModel.phoneNumber,
          farmLocation: farmLocation ?? existingModel.farmLocation,
          costPerLiterCow: costCow ?? existingModel.costPerLiterCow,
          costPerLiterBuffalo: costBuffalo ?? existingModel.costPerLiterBuffalo,
          createdAt: existingModel.createdAt,
          updatedAt: DateTime.now(), // Always update the timestamp
        );

        // Convert to model and check if any changes occurred
        final updatedModel = UserModel.fromEntity(updatedEntity);

        // Only update if there are actual changes
        final hasChanges =
            updatedModel.name != existingModel.name ||
                updatedModel.phoneNumber != existingModel.phoneNumber ||
                updatedModel.farmLocation != existingModel.farmLocation ||
                updatedModel.costPerLiterCow != existingModel.costPerLiterCow ||
                updatedModel.costPerLiterBuffalo != existingModel.costPerLiterBuffalo;

        if (hasChanges) {
          tx.update(docRef, updatedModel.toMap());
          dev.log('Updated user doc for ${user.uid}', name: 'UserRepository');
        } else {
          dev.log('No changes detected for user ${user.uid}', name: 'UserRepository');
        }
      }
    });
  }
}