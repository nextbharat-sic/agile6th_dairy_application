import '../backend/entities/expense_entity.dart';
import '../constants/constants.dart';

/// Presentation/data-transfer model class for expenses.
/// 
/// This model represents an expense in the presentation layer and provides
/// methods to convert between different data formats (Entity, Firestore, JSON).
/// 
/// The model includes:
/// - Basic expense information (id, date, category, description, amount)
/// - Conversion methods for different data sources
/// - Validation and data integrity checks
class ExpenseModel {
  final String id;
  final DateTime dateTime;
  final ExpenseCategory category;
  final String description;
  final double amount;

  ExpenseModel({
    required this.id,
    required this.dateTime,
    required this.category,
    required this.description,
    required this.amount,
  });

  /// Create a model from an entity.
  factory ExpenseModel.fromEntity(ExpenseEntity entity) {
    return ExpenseModel(
      id: entity.id,
      dateTime: entity.dateTime,
      category: ExpenseCategory.values.firstWhere(
        (cat) => cat.key == entity.category,
        orElse: () => ExpenseCategory.other,
      ),
      description: entity.description,
      amount: entity.amount,
    );
  }

  /// Create a model from Firestore data.
  factory ExpenseModel.fromMap(Map<String, dynamic> map, {String? documentId}) {
    try {
      print('Parsing expense from map: $map');
      print('Document ID: $documentId');
      
      // Handle legacy data that might have old field names
      final timestamp = map['timestamp'] ?? map['dateTime'];
      final category = map['category'];
      final description = map['description'];
      final amount = map['totalAmount'] ?? map['amount'];
      
      // Validate required fields with better error messages
      if (timestamp == null) {
        throw ArgumentError('timestamp/dateTime field is required but was null. Available fields: ${map.keys.toList()}');
      }
      if (category == null) {
        throw ArgumentError('category field is required but was null. Available fields: ${map.keys.toList()}');
      }
      if (description == null) {
        throw ArgumentError('description field is required but was null. Available fields: ${map.keys.toList()}');
      }
      if (amount == null) {
        throw ArgumentError('totalAmount/amount field is required but was null. Available fields: ${map.keys.toList()}');
      }

      // Parse timestamp safely
      DateTime dateTime;
      try {
        dateTime = DateTime.parse(timestamp.toString());
      } catch (e) {
        throw ArgumentError('Invalid timestamp format: $timestamp. Error: $e');
      }

      // Parse amount safely
      double amountValue;
      try {
        amountValue = (amount as num).toDouble();
      } catch (e) {
        throw ArgumentError('Invalid amount format: $amount. Error: $e');
      }

      // Parse category safely
      ExpenseCategory categoryValue;
      try {
        categoryValue = ExpenseCategory.values.firstWhere(
          (cat) => cat.key == category.toString(),
          orElse: () => ExpenseCategory.other,
        );
      } catch (e) {
        throw ArgumentError('Invalid category format: $category. Error: $e');
      }

      return ExpenseModel(
        id: documentId ?? map['id']?.toString() ?? '',
        dateTime: dateTime,
        category: categoryValue,
        description: description.toString(),
        amount: amountValue,
      );
    } catch (e) {
      print('Error parsing expense from map: $e');
      print('Map data: $map');
      print('Document ID: $documentId');
      rethrow;
    }
  }

  Map<String, dynamic> toMap() => {
    'timestamp': dateTime.toIso8601String(),  // Changed from 'dateTime' to match rules
    'dayKey': '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}',  // Added as required by rules
    'category': category.key,
    'description': description,
    'totalAmount': amount,  // Changed from 'amount' to match rules
    'createdAt': DateTime.now().toIso8601String(),  // Added as required by rules
    'updatedAt': DateTime.now().toIso8601String(),  // Added as required by rules
  };

  /// Check if a map can be safely converted to an ExpenseModel
  static bool canParse(Map<String, dynamic> map) {
    try {
      final timestamp = map['timestamp'] ?? map['dateTime'];
      final category = map['category'];
      final description = map['description'];
      final amount = map['totalAmount'] ?? map['amount'];
      
      return timestamp != null && 
             category != null && 
             description != null && 
             amount != null;
    } catch (e) {
      return false;
    }
  }
}
