import 'dart:developer' as dev;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

String _isoNow() => DateTime.now().toIso8601String();

double _round2(num v) => (v * 100).roundToDouble() / 100.0;

/// Build a rules-compliant user document payload.
/// NOTE: Your rules require createdAt/updatedAt as **strings**, not Timestamp.
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
    'costPerLiterCow': _round2((costCow ?? 50.0)),
    'costPerLiterBuffalo': _round2((costBuffalo ?? 55.0)),
    'updatedAt': _isoNow(), // string per rules
  };
  if (isCreate) {
    map['createdAt'] = _isoNow(); // string per rules
  }
  return map;
}

class UserRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  UserRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _db = firestore ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.collection('users').doc(uid);

  /// Preferred name (keeps your rules tight). Transaction ensures "create if absent" is atomic.
  Future<void> upsertUser({
    String? name,
    String? phoneNumber,
    String? farmLocation,
    double? costCow,
    double? costBuffalo,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('upsertUser: no signed-in user');

    final ref = _userDoc(user.uid);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);

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
        tx.set(ref, data);
        dev.log('Created user doc for ${user.uid}', name: 'UserRepository');
        return;
      }

      final old = snap.data() ?? const <String, dynamic>{};
      final update = <String, dynamic>{
        'updatedAt': _isoNow(), // string per rules
      };

      // Only change allowed keys; rules check changedKeys().
      void maybe(String key, dynamic value, dynamic oldValue) {
        if (value != null && value != oldValue) update[key] = value;
      }

      maybe('name', name, old['name']);
      maybe('phoneNumber', phoneNumber, old['phoneNumber']);
      maybe('farmLocation', farmLocation, old['farmLocation']);

      if (costCow != null) {
        maybe('costPerLiterCow', _round2(costCow), old['costPerLiterCow']);
      }
      if (costBuffalo != null) {
        maybe('costPerLiterBuffalo', _round2(costBuffalo),
            old['costPerLiterBuffalo']);
      }

      // IMPORTANT: do not touch uid/email on update (immutable by rules).
      tx.update(ref, update);
      dev.log('Updated user doc for ${user.uid}: $update',
          name: 'UserRepository');
    });
  }

  /// Back-compat alias so existing call sites keep working.
  Future<void> upsertUserOld({
    String? name,
    String? phoneNumber,
    String? farmLocation,
    double? costCow,
    double? costBuffalo,
  }) =>
      upsertUser(
        name: name,
        phoneNumber: phoneNumber,
        farmLocation: farmLocation,
        costCow: costCow,
        costBuffalo: costBuffalo,
      );

  /// Read once (owner reads are allowed by your rules).
  Future<Map<String, dynamic>?> fetch(String uid) async {
    final snap = await _userDoc(uid).get();
    return snap.data();
  }

  /// Live updates of the user doc.
  Stream<Map<String, dynamic>?> watch(String uid) =>
      _userDoc(uid).snapshots().map((s) => s.data());
}
