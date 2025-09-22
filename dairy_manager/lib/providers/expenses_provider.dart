import 'package:flutter/material.dart';
import '../../models/expense_model.dart';
import '../../constants/constants.dart';
import '../backend/services/expense_service.dart';

class ExpensesProvider extends ChangeNotifier {
  final ExpenseService _expenseService;
  
  // State variables
  List<ExpenseModel> _expenses = [];
  double _totalExpenses = 0.0;
  final Map<ExpenseCategory, double> _categoryTotals = {};
  bool _isLoading = false;
  String? _error;

  // Getters
  List<ExpenseModel> get expenses => _expenses;
  double get totalExpenses => _totalExpenses;
  Map<ExpenseCategory, double> get categoryTotals => _categoryTotals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ExpensesProvider(this._expenseService);

  /// Load expenses for a specific month and year
  Future<void> loadExpensesForMonth(String userId, int month, int year) async {
    _setLoading(true);
    _clearError();
    
    try {
      
      // First, clean up any invalid expenses
      await cleanupInvalidExpenses(userId);
      
      final expenses = await _expenseService.getExpensesForMonth(userId, month, year);
      _expenses = expenses;
      _calculateTotals();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load expenses: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Add a new expense
  Future<bool> addExpense({
    required String userId,
    required DateTime dateTime,
    required ExpenseCategory category,
    required String description,
    required double amount,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      
      await _expenseService.addExpense(
        userId: userId,
        dateTime: dateTime,
        category: category,
        description: description,
        amount: amount,
      );
      
      // CRITICAL FIX: Force reload of current expenses to ensure UI is updated
      // This prevents expenses from being replaced instead of added
      
      // CRITICAL FIX: Don't reload here - let the UI handle reloading for the selected month
      // This prevents the provider from switching to a different month than what the UI shows
      
      return true;
    } catch (e) {
      _setError('Failed to add expense: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Calculate totals from current expenses
  void _calculateTotals() {
    
    // CRITICAL FIX: Clear totals before recalculating to prevent accumulation errors
    _totalExpenses = 0.0;
    _categoryTotals.clear();
    
    // Calculate total expenses
    _totalExpenses = _expenses.fold(0.0, (total, expense) => total + expense.amount);
    
    // Calculate category totals - CRITICAL: Each expense should ADD to its category total
    for (final expense in _expenses) {
      final currentTotal = _categoryTotals[expense.category] ?? 0.0;
      final newTotal = currentTotal + expense.amount;
      _categoryTotals[expense.category] = newTotal;
      
    }
    
  }

  /// Clear expenses and reset state
  void clearExpenses() {
    _expenses.clear();
    _totalExpenses = 0.0;
    _categoryTotals.clear();
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clear error manually
  void clearError() {
    _clearError();
  }

  /// Clean up invalid expenses
  Future<void> cleanupInvalidExpenses(String userId) async {
    try {
      await _expenseService.cleanupInvalidExpenses(userId);
    } catch (e) {
      _setError('Failed to cleanup invalid expenses: $e');
    }
  }
}
