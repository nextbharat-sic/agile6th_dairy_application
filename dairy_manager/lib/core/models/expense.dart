import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String id;
  final DateTime timestampLocal;
  final String dayKey; // yyyyMMdd (local)
  final String category;
  final double totalAmount;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Expense({
    required this.id,
    required this.timestampLocal,
    required this.dayKey,
    required this.category,
    required this.totalAmount,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  static String dayKeyFromLocal(DateTime whenLocal) {
    final y = '${whenLocal.year}'.padLeft(4, '0');
    final m = '${whenLocal.month}'.padLeft(2, '0');
    final d = '${whenLocal.day}'.padLeft(2, '0');
    return '$y$m$d';
  }

  factory Expense.fromFirestore(String id, Map<String, dynamic> data) {
    final iso = (data['timestamp'] ?? '') as String;
    final whenLocal = DateTime.tryParse(iso)?.toLocal() ?? DateTime.now();

    // Robust amount parsing: accepts number or numeric string (legacy)
    final dynamic rawAmount = data['totalAmount'] ?? data['amount'];
    final double amt = rawAmount is num
        ? rawAmount.toDouble()
        : (rawAmount is String ? double.tryParse(rawAmount) ?? 0.0 : 0.0);

    Timestamp? created;
    if (data['createdAt'] is Timestamp) {
      created = data['createdAt'] as Timestamp;
    }
    Timestamp? updated;
    if (data['updatedAt'] is Timestamp) {
      updated = data['updatedAt'] as Timestamp;
    }

    return Expense(
      id: id,
      timestampLocal: whenLocal,
      dayKey: (data['dayKey'] as String?) ?? dayKeyFromLocal(whenLocal),
      category: (data['category'] as String?) ?? 'Uncategorized',
      totalAmount: _round2(amt),
      description: data['description'] as String?,
      createdAt: created?.toDate(),
      updatedAt: updated?.toDate(),
    );
  }

  Map<String, dynamic> toFirestoreCreate() => {
        'timestamp': timestampLocal.toIso8601String(), // local ISO
        'dayKey': dayKey,
        'category': category,
        'description': description,
        'totalAmount': totalAmount,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }..removeWhere((k, v) => v == null);

  Map<String, dynamic> toFirestoreUpdate() => {
        'category': category,
        'description': description,
        'totalAmount': totalAmount,
        'updatedAt': FieldValue.serverTimestamp(),
      }..removeWhere((k, v) => v == null);
}

double _round2(double v) => (v * 100).roundToDouble() / 100.0;
