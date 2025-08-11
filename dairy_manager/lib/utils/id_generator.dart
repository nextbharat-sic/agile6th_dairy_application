import 'date_utils.dart';

class IdGenerator {
  /// Generates incomeId in 'yyyyMMdd_HHmmss' format, local timezone.
  static String generateIncomeId(DateTime dateTime) =>
     DateUtils.convertToDatetimeString(dateTime);
}
