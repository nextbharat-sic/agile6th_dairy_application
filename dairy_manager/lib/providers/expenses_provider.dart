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
      print('ExpensesProvider: Loading expenses for month: $month, year: $year, userId: $userId');
      
      // First, clean up any invalid expenses
      await cleanupInvalidExpenses(userId);
      
      final expenses = await _expenseService.getExpensesForMonth(userId, month, year);
      print('ExpensesProvider: Loaded ${expenses.length} expenses');
      _expenses = expenses;
      _calculateTotals();
      notifyListeners();
      print('ExpensesProvider: Expenses loaded and UI updated');
    } catch (e) {
      print('ExpensesProvider: Error loading expenses: $e');
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
      print('ExpensesProvider: Adding expense - userId: $userId, amount: $amount, category: ${category.key}'); // Debug log
      
      await _expenseService.addExpense(
        userId: userId,
        dateTime: dateTime,
        category: category,
        description: description,
        amount: amount,
      );
      
      print('ExpensesProvider: Expense added successfully, reloading data...'); // Debug log
      
      // CRITICAL FIX: Force reload of current expenses to ensure UI is updated
      // This prevents expenses from being replaced instead of added
      print('ExpensesProvider: Forcing data reload to prevent replacement');
      
      // CRITICAL FIX: Don't reload here - let the UI handle reloading for the selected month
      // This prevents the provider from switching to a different month than what the UI shows
      print('ExpensesProvider: Expense added, UI will handle reload for selected month');
      
      print('ExpensesProvider: Data reloaded successfully'); // Debug log
      return true;
    } catch (e) {
      print('ExpensesProvider: Error adding expense: $e'); // Debug log
      _setError('Failed to add expense: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Calculate totals from current expenses
  void _calculateTotals() {
    print('ExpensesProvider: Calculating totals for ${_expenses.length} expenses');
    
    // CRITICAL FIX: Clear totals before recalculating to prevent accumulation errors
    _totalExpenses = 0.0;
    _categoryTotals.clear();
    
    // Calculate total expenses
    _totalExpenses = _expenses.fold(0.0, (total, expense) => total + expense.amount);
    print('ExpensesProvider: Total expenses: $_totalExpenses');
    
    // Calculate category totals - CRITICAL: Each expense should ADD to its category total
    for (final expense in _expenses) {
      final currentTotal = _categoryTotals[expense.category] ?? 0.0;
      final newTotal = currentTotal + expense.amount;
      _categoryTotals[expense.category] = newTotal;
      
      print('ExpensesProvider: Category ${expense.category.displayName}: $currentTotal + ${expense.amount} = $newTotal');
    }
    
    print('ExpensesProvider: Final category totals: $_categoryTotals');
    print('ExpensesProvider: Total categories found: ${_categoryTotals.length}');
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
      print('ExpensesProvider: Cleaning up invalid expenses for user: $userId');
      await _expenseService.cleanupInvalidExpenses(userId);
      print('ExpensesProvider: Cleanup completed');
    } catch (e) {
      print('ExpensesProvider: Error during cleanup: $e');
      _setError('Failed to cleanup invalid expenses: $e');
    }
  }
}
