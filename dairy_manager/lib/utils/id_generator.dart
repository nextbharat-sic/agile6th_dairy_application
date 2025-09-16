import '../constants/constants.dart';
import 'date_utils.dart';

/// A utility class for generating various IDs.
class IdGenerator {
  /// Generates expenseId in 'yyyyMMdd_HHmmss' format, local timezone.
  /// CRITICAL FIX: Added milliseconds to ensure unique IDs for multiple expenses on same day
  static String generateExpenseId(DateTime dateTime) {
    final now = DateTime.now();
    return '${DateUtils.convertToDatetimeString(dateTime)}_${now.millisecondsSinceEpoch % 1000000}';
  }
  /// Generates incomeId in 'YYYYMMDD_session_animalType' format, local timezone.
  /// Example: 20231027_MORNING_COW
  static String generateIncomeId(DateTime dateTime, SessionType session, AnimalType animalType) =>
      '${DateUtils.convertToDateString(dateTime)}_${session.name}_${animalType.name}';
}
