import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/models/expense.dart';
import '../core/repositories/expenses_repository.dart';

double _round2(double v) => (v * 100).roundToDouble() / 100.0;

class ExpensesProvider extends ChangeNotifier {
  final ExpensesRepository repo;
  final String userId;

  ExpensesProvider({required this.repo, required this.userId});

  List<Expense> _items = [];
  List<Expense> get items => _items;

  bool _loading = false;
  bool get loading => _loading;

  StreamSubscription<List<Expense>>? _sub;

  /// Bind a date range [from, to] inclusive
  void bindRange(DateTime from, DateTime to) {
    _loading = true;
    notifyListeners();
    _sub?.cancel();
    _sub = repo
        .watchRange(
      userId: userId,
      startLocalInclusive: from,
      endLocalInclusive: to,
    )
        .listen((list) {
      _items = list;
      _loading = false;
      notifyListeners();
    }, onError: (e, st) {
      _loading = false; // don’t get stuck spinning
      notifyListeners();
    });
  }

  Future<String> add({
    required DateTime when,
    required String category,
    required double amount,
    String? description,
  }) {
    return repo.addExpense(
      userId: userId,
      whenLocal: when,
      category: category,
      amount: _round2(amount),
      description: description,
    );
  }

  /// Atomic add of multiple categories in one call (recommended from UI)
  Future<void> addBatch({
    required DateTime when,
    required Map<String, double> categoryToAmount,
    String? description,
  }) {
    // round client-side for consistency
    final rounded = <String, double>{
      for (final e in categoryToAmount.entries)
        if (e.value > 0) e.key: _round2(e.value),
    };
    return repo.addBatch(
      userId: userId,
      whenLocal: when,
      categoryToAmount: rounded,
      description: description,
    );
  }

  Future<void> update({
    required String expenseId,
    String? category,
    String? description,
    double? amount,
    DateTime? when,
  }) {
    return repo.updateExpense(
      userId: userId,
      expenseId: expenseId,
      category: category,
      description: description,
      amount: amount == null ? null : _round2(amount),
      whenLocal: when,
    );
  }

  Future<void> remove(String expenseId) =>
      repo.deleteExpense(userId: userId, expenseId: expenseId);

  /// Sum by category using the flat schema (category + totalAmount)
  Map<String, double> totalsByCategory() {
    final totals = <String, double>{};
    for (final e in _items) {
      totals[e.category] = _round2((totals[e.category] ?? 0) + e.totalAmount);
    }
    return totals;
  }

  double totalAmount() =>
      _round2(_items.fold(0.0, (a, e) => a + e.totalAmount));

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
