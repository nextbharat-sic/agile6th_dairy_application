import 'package:intl/intl.dart';
import '../constants/constants.dart'; // For GroupByFrequency enum

/// A centralized collection of utility functions for handling and manipulating dates.
class DateUtils {
  /// Generates datetime in 'yyyyMMdd_HHmmss' format, local timezone.
  static String convertToDatetimeString(DateTime dateTime) =>
      DateFormat('yyyyMMdd_HHmmss').format(dateTime);

  /// Generates datetime in 'yyyyMMdd' format, local timezone.
  static String convertToDateString(DateTime dateTime) =>
      DateFormat('yyyyMMdd').format(dateTime);

  /// Returns the start of the day for the given [dateTime].
  static DateTime getStartOfDay(DateTime dateTime) =>
      DateTime(dateTime.year, dateTime.month, dateTime.day);

  /// Returns the end of the day for the given [dateTime].
  static DateTime getEndOfDay(DateTime dateTime) => DateTime(
      dateTime.year, dateTime.month, dateTime.day, 23, 59, 59, 999, 999);

  /// Checks if a start date is on or before an end date.
  static bool isStartBeforeOrEqualEnd(
          {required DateTime startDate, required DateTime endDate}) =>
      !startDate.isAfter(endDate);

  /// Generates a unique, consistent key for a date based on the grouping frequency.
  /// This is the "internal label" used for sorting data.
  static String generateGroupKeyForDate(
      DateTime date, GroupByFrequency groupBy) {
    switch (groupBy) {
      case GroupByFrequency.day:
        return DateFormat('yyyy-MM-dd').format(date);
      case GroupByFrequency.week:
        final weekOfMonth = (date.day - 1) ~/ 7 + 1;
        return "${DateFormat('yyyy-MM').format(date)}-W$weekOfMonth";
      case GroupByFrequency.month:
        return DateFormat('yyyy-MM').format(date);
      case GroupByFrequency.quarter:
        final quarter = (date.month - 1) ~/ 3 + 1;
        return "${date.year}-Q$quarter";
      case GroupByFrequency.year:
        return date.year.toString();
    }
  }

  /// Converts an internal group key into a user-friendly name for the final report.
  /// This is the "public label" that the user will see.
  static String generateDisplayKeyForGroup(
      String groupKey, GroupByFrequency groupBy) {
    switch (groupBy) {
      case GroupByFrequency.day:
        return DateFormat.E().format(DateTime.parse(groupKey)); // e.g., 'Sat'
      case GroupByFrequency.week:
        return "Week${groupKey.split('-W').last}"; // e.g., 'Week1'
      case GroupByFrequency.month:
        return DateFormat.MMM()
            .format(DateTime.parse("${groupKey}-01")); // e.g., 'Sep'
      case GroupByFrequency.quarter:
        return groupKey.split('-').last; // e.g., 'Q3'
      case GroupByFrequency.year:
        return groupKey; // e.g., '2025'
    }
  }

  /// Advances a date to the start of the next period based on the grouping frequency.
  /// This is used to iterate through time to build the report skeleton.
  static DateTime advanceDateToNextGroup(
      DateTime date, GroupByFrequency groupBy) {
    switch (groupBy) {
      case GroupByFrequency.day:
        return date.add(const Duration(days: 1));
      case GroupByFrequency.week:
        return date.add(const Duration(days: 7));
      case GroupByFrequency.month:
        return DateTime(date.year, date.month + 1, 1);
      case GroupByFrequency.quarter:
        return DateTime(date.year, date.month + 3, 1);
      case GroupByFrequency.year:
        return DateTime(date.year + 1, 1, 1);
    }
  }

  /// Returns the current date (today).
  static DateTime getToday() => DateTime.now();

  /// Returns the first day of the current year.
  static DateTime getFirstDayOfYear() => DateTime(DateTime.now().year, 1, 1);
}
