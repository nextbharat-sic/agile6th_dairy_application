// validators/number_validator.dart
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
}
