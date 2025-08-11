import 'dart:developer' as dev;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

String _isoNow() => DateTime.now().toIso8601String();

Map<String, dynamic> _buildUserDoc({
  required User authUser,
  String? name,
  String? phoneNumber,
  String? farmLocation,
  double? costCow,
  double? costBuffalo,
  bool isCreate = false,
}) {
  final map = <String, dynamic>{
    'uid': authUser.uid,
    'name': name ?? authUser.displayName ?? '',
    'email': authUser.email ?? '',
    'phoneNumber': phoneNumber ?? '',
    'farmLocation': farmLocation ?? '',
    'costPerLiterCow': (costCow ?? 50.0).toDouble(),
    'costPerLiterBuffalo': (costBuffalo ?? 55.0).toDouble(),
    'updatedAt': _isoNow(),
  };
  if (isCreate) {
    map['createdAt'] = _isoNow();
  }
  return map;
}

class UserRepository {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Future<void> upsertUserOld({
    String? name,
    String? phoneNumber,
    String? farmLocation,
    double? costCow,
    double? costBuffalo,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('upsertUserOld: no signed-in user');

    final docRef = _db.collection('users').doc(user.uid);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(docRef);

      if (!snap.exists) {
        final data = _buildUserDoc(
          authUser: user,
          name: name,
          phoneNumber: phoneNumber,
          farmLocation: farmLocation,
          costCow: costCow,
          costBuffalo: costBuffalo,
          isCreate: true,
        );
        tx.set(docRef, data);
        dev.log('Created user doc for ${user.uid}', name: 'UserRepository');
      } else {
        final old = snap.data() ?? const <String, dynamic>{};

        final update = <String, dynamic>{
          'updatedAt': _isoNow(),
        };

        void maybe(String key, dynamic value, dynamic oldValue) {
          if (value != null && value != oldValue) update[key] = value;
        }

        maybe('name', name, old['name']);
        maybe('phoneNumber', phoneNumber, old['phoneNumber']);
        maybe('farmLocation', farmLocation, old['farmLocation']);
        if (costCow != null)
          maybe('costPerLiterCow', costCow, old['costPerLiterCow']);
        if (costBuffalo != null)
          maybe('costPerLiterBuffalo', costBuffalo, old['costPerLiterBuffalo']);

        tx.update(docRef, update);
        dev.log('Updated user doc for ${user.uid}: $update',
            name: 'UserRepository');
      }
    });
  }
}
