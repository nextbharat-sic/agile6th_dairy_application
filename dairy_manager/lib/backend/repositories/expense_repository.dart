import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/expense_model.dart';
import '../../constants/constants.dart';

/// Repository class for managing expense data operations with Firestore.
/// 
/// This repository handles all data persistence and retrieval operations
/// for expenses, providing a clean abstraction over the Firestore database.
/// 
/// Responsibilities:
/// - CRUD operations for expense data
/// - Query optimization and filtering
/// - Data transformation between Firestore and models
/// - Error handling and data validation
class ExpenseRepository {
  final FirebaseFirestore firestore;

  ExpenseRepository(this.firestore);

  /// Add a new expense record
  Future<void> addExpense(String userId, String expenseId, ExpenseModel model) async {
    try {
      await firestore.runTransaction((transaction) async {
        // Check if user document exists
        final userDocRef = firestore.collection('users').doc(userId);
        final userDoc = await transaction.get(userDocRef);
        
        // If user document doesn't exist, create a basic one
        if (!userDoc.exists) {
          final basicUserData = {
            'uid': userId,
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
          };
          transaction.set(userDocRef, basicUserData);
        }
        
        // Now add the expense
        final expenseDocRef = userDocRef.collection('expenses').doc(expenseId);
        final expenseData = model.toMap();
        print('Adding expense data: $expenseData'); // Debug log
        transaction.set(expenseDocRef, expenseData);
      });
    } catch (e) {
      print('Error adding expense: $e'); // Debug log
      rethrow;
    }
  }

  /// Get all expenses for a user within a date range
  Future<List<ExpenseModel>> getExpenses(
    String userId, 
    DateTime startDateTime, 
    DateTime endDateTime
  ) async {
    try {
      print('Fetching expenses for user: $userId, from: $startDateTime to: $endDateTime');
      
      final startTimestamp = startDateTime.toIso8601String();
      final endTimestamp = endDateTime.toIso8601String();
      
      print('Querying with timestamp range: $startTimestamp to $endTimestamp');
      
      final snapshot = await firestore.collection('users').doc(userId)
          .collection('expenses')
          .where('timestamp', isGreaterThanOrEqualTo: startTimestamp)
          .where('timestamp', isLessThanOrEqualTo: endTimestamp)
          .orderBy('timestamp', descending: true)
          .get();

      print('Found ${snapshot.docs.length} expenses');
      
      final expenses = snapshot.docs.where((doc) {
        final canParse = ExpenseModel.canParse(doc.data());
        if (!canParse) {
          print('Skipping invalid document ${doc.id}: ${doc.data()}');
        }
        return canParse;
      }).map((doc) {
        print('Processing document ${doc.id} with data: ${doc.data()}');
        return ExpenseModel.fromMap(doc.data(), documentId: doc.id);
      }).toList();
      
      print('Successfully parsed ${expenses.length} expenses');
      return expenses;
    } catch (e) {
      print('Error fetching expenses: $e');
      rethrow;
    }
  }

  /// Get total expenses for a user within a date range
  Future<double> getTotalExpenses(
    String userId, 
    DateTime startDateTime, 
    DateTime endDateTime
  ) async {
    final expenses = await getExpenses(userId, startDateTime, endDateTime);
    return expenses.fold<double>(0.0, (total, expense) => total + expense.amount);
  }

  /// Get expenses by category for a user within a date range
  Future<Map<ExpenseCategory, double>> getExpensesByCategory(
    String userId, 
    DateTime startDateTime, 
    DateTime endDateTime
  ) async {
    final expenses = await getExpenses(userId, startDateTime, endDateTime);
    final Map<ExpenseCategory, double> categoryTotals = {};
    
    for (final expense in expenses) {
      categoryTotals[expense.category] = 
          (categoryTotals[expense.category] ?? 0.0) + expense.amount;
    }
    
    return categoryTotals;
  }

  /// Get recent expenses for a user (last 10)
  Future<List<ExpenseModel>> getRecentExpenses(String userId) async {
    try {
      print('Fetching recent expenses for user: $userId');
      
      final snapshot = await firestore.collection('users').doc(userId)
          .collection('expenses')
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();

      print('Found ${snapshot.docs.length} recent expenses');
      
      final expenses = snapshot.docs.where((doc) {
        final canParse = ExpenseModel.canParse(doc.data());
        if (!canParse) {
          print('Skipping invalid recent expense document ${doc.id}: ${doc.data()}');
        }
        return canParse;
      }).map((doc) => ExpenseModel.fromMap(doc.data(), documentId: doc.id)).toList();
      
      print('Successfully parsed ${expenses.length} recent expenses');
      return expenses;
    } catch (e) {
      print('Error fetching recent expenses: $e');
      rethrow;
    }
  }

  /// Delete an expense
  Future<void> deleteExpense(String userId, String expenseId) async {
    await firestore.collection('users').doc(userId)
        .collection('expenses').doc(expenseId)
        .delete();
  }

  /// Update an expense
  Future<void> updateExpense(String userId, String expenseId, ExpenseModel model) async {
    await firestore.collection('users').doc(userId)
        .collection('expenses').doc(expenseId)
        .update(model.toMap());
  }

  /// Clean up invalid expense documents
  Future<void> cleanupInvalidExpenses(String userId) async {
    try {
      print('Cleaning up invalid expenses for user: $userId');
      
      final snapshot = await firestore.collection('users').doc(userId)
          .collection('expenses')
          .get();

      int cleanedCount = 0;
      for (final doc in snapshot.docs) {
        if (!ExpenseModel.canParse(doc.data())) {
          print('Deleting invalid expense document: ${doc.id}');
          await doc.reference.delete();
          cleanedCount++;
        }
      }
      
      print('Cleaned up $cleanedCount invalid expense documents');
    } catch (e) {
      print('Error cleaning up invalid expenses: $e');
      rethrow;
    }
  }
}
