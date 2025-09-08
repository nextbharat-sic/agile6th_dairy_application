// validators/number_validator.dart
import 'date_utils.dart';

class Validator {
  static void validatePositiveNumber(String name, double value) {
    if (value <= 0) {
      throw ArgumentError('$name must be positive.');
    }
  }

  static void validateNonNegativeNumber(String name, double value) {
    if (value < 0) {
      throw ArgumentError('$name cannot be negative.');
    }
  }

  static void validateDateRange(
      {required DateTime startDate, required DateTime endDate}) {
    if (!DateUtils.isStartBeforeOrEqualEnd(
        startDate: startDate, endDate: endDate)) {
      throw ArgumentError(
          'The report start date cannot be after the end date.');
    }
  }
}
