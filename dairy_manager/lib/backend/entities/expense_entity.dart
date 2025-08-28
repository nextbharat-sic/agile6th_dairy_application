import '../../constants/constants.dart';

/// Entity class for expense data validation and business logic.
/// 
/// This entity represents the core business logic for expenses,
/// including validation rules and data integrity constraints.
/// 
/// Responsibilities:
/// - Validate expense data before persistence
/// - Ensure business rule compliance
/// - Provide clean data structure for the domain layer
class ExpenseEntity {
  final String id;
  final DateTime dateTime;
  final String category;
  final String description;
  final double amount;

  ExpenseEntity({
    required this.id,
    required this.dateTime,
    required this.category,
    required this.description,
    required this.amount,
  }) {
    _validate();
  }

  /// Validate expense data according to business rules
  void _validate() {
    if (id.isEmpty) {
      throw ArgumentError('Expense ID cannot be empty');
    }
    
    if (dateTime.isAfter(DateTime.now())) {
      throw ArgumentError('Expense date cannot be in the future');
    }
    
    if (description.trim().isEmpty) {
      throw ArgumentError('Expense description cannot be empty');
    }
    
    if (amount <= 0) {
      throw ArgumentError('Expense amount must be greater than zero');
    }
    
    // Validate category is one of the allowed values
    final validCategories = ExpenseCategory.values.map((cat) => cat.key).toList();
    if (!validCategories.contains(category)) {
      throw ArgumentError('Invalid expense category: $category');
    }
  }

  /// Create a copy of this entity with updated values
  ExpenseEntity copyWith({
    String? id,
    DateTime? dateTime,
    String? category,
    String? description,
    double? amount,
  }) {
    return ExpenseEntity(
      id: id ?? this.id,
      dateTime: dateTime ?? this.dateTime,
      category: category ?? this.category,
      description: description ?? this.description,
      amount: amount ?? this.amount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExpenseEntity &&
        other.id == id &&
        other.dateTime == dateTime &&
        other.category == category &&
        other.description == description &&
        other.amount == amount;
  }

  @override
  int get hashCode {
    return Object.hash(id, dateTime, category, description, amount);
  }

  @override
  String toString() {
    return 'ExpenseEntity(id: $id, dateTime: $dateTime, category: $category, description: $description, amount: $amount)';
  }
}

