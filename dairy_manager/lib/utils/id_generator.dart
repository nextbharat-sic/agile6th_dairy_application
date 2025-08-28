import 'date_utils.dart';

class IdGenerator {
  /// Generates incomeId in 'yyyyMMdd_HHmmss' format, local timezone.
  static String generateIncomeId(DateTime dateTime) =>
     DateUtils.convertToDatetimeString(dateTime);
     
  /// Generates expenseId in 'yyyyMMdd_HHmmss' format, local timezone.
  /// CRITICAL FIX: Added milliseconds to ensure unique IDs for multiple expenses on same day
  static String generateExpenseId(DateTime dateTime) {
    final now = DateTime.now();
    return '${DateUtils.convertToDatetimeString(dateTime)}_${now.millisecondsSinceEpoch % 1000000}';
  }
}
