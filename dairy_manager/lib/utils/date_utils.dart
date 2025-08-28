import 'package:intl/intl.dart';

class DateUtils {
  /// Generates datetime in 'yyyyMMdd_HHmmss' format, local timezone.
  static String convertToDateString(DateTime dateTime) =>
      DateFormat('yyyyMMdd').format(dateTime);

  /// Returns the start of the day for the given [dateTime].
  static DateTime getStartOfDay(DateTime dateTime) =>
      DateTime(dateTime.year, dateTime.month, dateTime.day);

  /// Returns the end of the day for the given [dateTime].
  static DateTime getEndOfDay(DateTime dateTime) => DateTime(
      dateTime.year, dateTime.month, dateTime.day, 23, 59, 59, 999, 999);
}

