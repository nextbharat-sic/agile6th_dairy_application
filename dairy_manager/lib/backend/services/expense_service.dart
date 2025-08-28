import 'dart:developer';
import '../../models/expense_model.dart';
import '../../utils/id_generator.dart';
import '../../constants/constants.dart';
import '../entities/expense_entity.dart';
import '../repositories/expense_repository.dart';

/// Service class for managing expense operations and business logic.
/// 
/// This service acts as an intermediary between the presentation layer
/// and the data layer, handling business logic, validation, and
/// orchestration of expense-related operations.
/// 
/// Responsibilities:
/// - Coordinate between entities and repositories
/// - Handle business logic and validation
/// - Provide a clean API for expense operations
/// - Manage data transformation and mapping
class ExpenseService {
  final ExpenseRepository expenseRepo;

  ExpenseService({
    required this.expenseRepo,
  });

  /// Adds a new expense record and returns the expense details
  Future<Map<String, dynamic>> addExpense({
    required String userId,
    required DateTime dateTime,
    required ExpenseCategory category,
    required String description,
    required double amount,
  }) async {
    try {
      log('Adding expense: userId=$userId, category=${category.key}, amount=$amount');
      
      // 1. Generate a unique ID
      final expenseId = IdGenerator.generateExpenseId(dateTime);

      // 2. Create the entity (validation)
      final expenseEntity = ExpenseEntity(
        id: expenseId,
        dateTime: dateTime,
        category: category.key,
        description: description,
        amount: amount,
      );

      // 3. Map entity to model and persist (repository handles user document creation)
      final expenseModel = ExpenseModel.fromEntity(expenseEntity);
      log('Expense model created: ${expenseModel.toMap()}'); // Debug log
      
      await expenseRepo.addExpense(userId, expenseId, expenseModel);

      log('Expense added successfully: expenseId=$expenseId');

      // 4. Return summary
      return {
        'expenseId': expenseId,
        'category': category.key,
        'description': description,
        'amount': amount,
        'dateTime': dateTime.toIso8601String(),
      };
    } catch (e) {
      log('Error adding expense: $e', error: e);
      rethrow;
    }
  }

  /// Get expenses for a specific month and year
  Future<List<ExpenseModel>> getExpensesForMonth(
    String userId, 
    int month, 
    int year
  ) async {
    try {
      log('Fetching expenses for month: userId=$userId, month=$month, year=$year');
      
      // Create proper date range for the month
      final startDate = DateTime(year, month, 1);
      final endDate = month == 12 
          ? DateTime(year + 1, 1, 1).subtract(Duration(milliseconds: 1))
          : DateTime(year, month + 1, 1).subtract(Duration(milliseconds: 1));
      
      log('Date range: $startDate to $endDate');
      
      final expenses = await expenseRepo.getExpenses(userId, startDate, endDate);
      log('Fetched ${expenses.length} expenses for month');
      
      return expenses;
    } catch (e) {
      log('Error fetching expenses for month: $e', error: e);
      rethrow;
    }
  }

  /// Get total expenses for a specific month and year
  Future<double> getTotalExpensesForMonth(
    String userId, 
    int month, 
    int year
  ) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);
    
    return await expenseRepo.getTotalExpenses(userId, startDate, endDate);
  }

  /// Get expenses by category for a specific month and year
  Future<Map<ExpenseCategory, double>> getExpensesByCategoryForMonth(
    String userId, 
    int month, 
    int year
  ) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);
    
    return await expenseRepo.getExpensesByCategory(userId, startDate, endDate);
  }

  /// Get recent expenses
  Future<List<ExpenseModel>> getRecentExpenses(String userId) async {
    return await expenseRepo.getRecentExpenses(userId);
  }

  /// Delete an expense
  Future<void> deleteExpense(String userId, String expenseId) async {
    await expenseRepo.deleteExpense(userId, expenseId);
  }

  /// Update an expense
  Future<void> updateExpense({
    required String userId,
    required String expenseId,
    required DateTime dateTime,
    required ExpenseCategory category,
    required String description,
    required double amount,
  }) async {
    final expenseEntity = ExpenseEntity(
      id: expenseId,
      dateTime: dateTime,
      category: category.key,
      description: description,
      amount: amount,
    );

    final expenseModel = ExpenseModel.fromEntity(expenseEntity);
    await expenseRepo.updateExpense(userId, expenseId, expenseModel);
  }

  /// Clean up invalid expense documents
  Future<void> cleanupInvalidExpenses(String userId) async {
    await expenseRepo.cleanupInvalidExpenses(userId);
  }
}
