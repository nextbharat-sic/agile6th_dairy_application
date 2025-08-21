import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense.dart';

double _r2(double v) => (v * 100).roundToDouble() / 100.0;

class ExpensesRepository {
  final FirebaseFirestore _db;
  ExpensesRepository(this._db);

  DocumentReference<Map<String, dynamic>> _userRef(String uid) =>
      _db.collection('users').doc(uid);
  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _userRef(uid).collection('expenses');

  // ──────────────────────────── CREATE ────────────────────────────

  /// One doc per category (auto-ID ⇒ no collisions).
  Future<String> add({
    required String userId,
    required DateTime whenLocal,
    required String category,
    required double amount,
    String? description,
  }) async {
    final doc = _col(userId).doc();
    final payload = Expense(
      id: doc.id,
      timestampLocal: whenLocal,
      dayKey: Expense.dayKeyFromLocal(whenLocal),
      category: category,
      totalAmount: _r2(amount),
      description: description,
      createdAt: null,
      updatedAt: null,
    ).toFirestoreCreate();

    await doc.set(payload, SetOptions(merge: false));
    return doc.id;
  }

  /// Atomic multi-insert for "enter many fields then Save".
  Future<void> addBatch({
    required String userId,
    required DateTime whenLocal,
    required Map<String, double> categoryToAmount,
    String? description,
  }) async {
    final batch = _db.batch();
    final dayKey = Expense.dayKeyFromLocal(whenLocal);
    final iso = whenLocal.toIso8601String();

    categoryToAmount.forEach((category, amount) {
      if (amount <= 0) return;
      final doc = _col(userId).doc();
      batch.set(
          doc,
          {
            'timestamp': iso,
            'dayKey': dayKey,
            'category': category,
            'description': description,
            'totalAmount': _r2(amount),
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          }..removeWhere((k, v) => v == null));
    });

    await batch.commit();
  }

  // ───────────────────────────── READ ─────────────────────────────

  /// Month stream using ISO-string range (fits your current rules).
  Stream<List<Expense>> watchForMonth({
    required String userId,
    required int year,
    required int month,
  }) {
    final start = DateTime(year, month, 1);
    final end =
        (month == 12) ? DateTime(year + 1, 1, 1) : DateTime(year, month + 1, 1);
    final startIso = start.toIso8601String();
    final endIso = end.toIso8601String();

    final q = _col(userId)
        .where('timestamp', isGreaterThanOrEqualTo: startIso)
        .where('timestamp', isLessThan: endIso)
        .orderBy('timestamp', descending: true);

    return q.snapshots().map((snap) =>
        snap.docs.map((d) => Expense.fromFirestore(d.id, d.data())).toList());
  }

  /// Legacy-compatible overload matching your provider’s param names.
  /// Accepts either (startLocal,endLocal) EXCLUSIVE end,
  /// or (startLocalInclusive,endLocalInclusive) INCLUSIVE end.
  Stream<List<Expense>> watchRange({
    required String userId,
    DateTime? startLocal,
    DateTime? endLocal, // exclusive
    DateTime? startLocalInclusive, // used by provider
    DateTime? endLocalInclusive, // inclusive
  }) {
    final DateTime start = startLocal ?? startLocalInclusive!;
    final DateTime endExclusive =
        endLocal ?? endLocalInclusive!.add(const Duration(milliseconds: 1));

    final startIso = start.toIso8601String();
    final endIso = endExclusive.toIso8601String();

    final q = _col(userId)
        .where('timestamp', isGreaterThanOrEqualTo: startIso)
        .where('timestamp', isLessThan: endIso)
        .orderBy('timestamp', descending: true);

    return q.snapshots().map((snap) =>
        snap.docs.map((d) => Expense.fromFirestore(d.id, d.data())).toList());
  }

  // ──────────────────────── UPDATE / DELETE ───────────────────────

  /// Update any allowed field; optionally move the entry to a new date.
  Future<void> update({
    required String userId,
    required String expenseId,
    String? category,
    double? amount,
    String? description,
    DateTime? whenLocal, // change date if provided
  }) async {
    final patch = <String, dynamic>{
      if (category != null) 'category': category,
      if (amount != null) 'totalAmount': _r2(amount),
      if (description != null) 'description': description,
      if (whenLocal != null) ...{
        'timestamp': whenLocal.toIso8601String(),
        'dayKey': Expense.dayKeyFromLocal(whenLocal),
      },
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await _col(userId).doc(expenseId).update(patch);
  }

  Future<void> delete({
    required String userId,
    required String expenseId,
  }) =>
      _col(userId).doc(expenseId).delete();

  // ───────────────────────── AGGREGATIONS ─────────────────────────

  static double sumAmount(Iterable<Expense> items) =>
      _r2(items.fold(0.0, (a, e) => a + e.totalAmount));

  static Map<String, double> sumByCategory(Iterable<Expense> items) {
    final out = <String, double>{};
    for (final e in items) {
      out[e.category] = _r2((out[e.category] ?? 0) + e.totalAmount);
    }
    return out;
  }

  // ─────────────── LEGACY ALIASES (provider compatibility) ───────────────

  Future<String> addExpense({
    required String userId,
    required DateTime whenLocal,
    required String category,
    required double amount,
    String? description,
  }) =>
      add(
        userId: userId,
        whenLocal: whenLocal,
        category: category,
        amount: amount,
        description: description,
      );

  Future<void> updateExpense({
    required String userId,
    required String expenseId,
    String? category,
    String? description,
    double? amount,
    DateTime? whenLocal, // provider passes this
  }) =>
      update(
        userId: userId,
        expenseId: expenseId,
        category: category,
        amount: amount,
        description: description,
        whenLocal: whenLocal,
      );

  Future<void> deleteExpense({
    required String userId,
    required String expenseId,
  }) =>
      delete(userId: userId, expenseId: expenseId);
}
