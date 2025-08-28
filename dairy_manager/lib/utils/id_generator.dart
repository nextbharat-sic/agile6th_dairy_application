import '../constants/constants.dart';
import 'date_utils.dart';

/// A utility class for generating various IDs.
class IdGenerator {
  /// Generates incomeId in 'YYYYMMDD_session_animalType' format, local timezone.
  /// Example: 20231027_MORNING_COW
  static String generateIncomeId(DateTime dateTime, SessionType session, AnimalType animalType) =>
      '${DateUtils.convertToDateString(dateTime)}_${session.name}_${animalType.name}';
}
