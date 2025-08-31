enum AnimalType { cow, buffalo }

extension AnimalTypeExtension on AnimalType {
  String get key => toString().split('.').last;
}

enum SessionType { morning, evening }

extension SessionTypeExtension on SessionType {
  String get key => toString().split('.').last;
}

/// Categories for expense tracking in the dairy management system
/// 
/// Each category represents a different type of expense that dairy farmers
/// commonly encounter in their operations.
enum ExpenseCategory { 
  /// Animal feed and nutrition costs
  feed, 
  
  /// Labor and staffing costs
  labour, 
  
  /// Veterinary care and animal health expenses
  healthcare, 
  
  /// Electricity, water, and other utility costs
  utilities, 
  
  /// Equipment, machinery, and maintenance costs
  equipment, 
  
  /// Miscellaneous and other expenses
  other 
}

extension ExpenseCategoryExtension on ExpenseCategory {
  String get key => toString().split('.').last;
  
  String get displayName {
    switch (this) {
      case ExpenseCategory.feed:
        return 'Feed';
      case ExpenseCategory.labour:
        return 'Labour';
      case ExpenseCategory.healthcare:
        return 'Healthcare';
      case ExpenseCategory.utilities:
        return 'Utilities';
      case ExpenseCategory.equipment:
        return 'Equipment';
      case ExpenseCategory.other:
        return 'Other';
    }
  }
}
