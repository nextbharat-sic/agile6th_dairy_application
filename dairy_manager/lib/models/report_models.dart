// file: lib/models/report_model.dart

import 'package:intl/intl.dart';

import '../constants/constants.dart';

/// A data class holding core metrics related to animal output or "yield".
class YieldMetrics {
  final double income;
  final double milkQuantity;
  final double avgFat;
  final double avgSnf;

  const YieldMetrics({
    this.income = 0.0,
    this.milkQuantity = 0.0,
    this.avgFat = 0.0,
    this.avgSnf = 0.0,
  });

  /// Serializes this object to a JSON-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'income': income,
      'milk_quantity': milkQuantity,
      'avg_fat': avgFat,
      'avg_snf': avgSnf,
    };
  }
}

/// Represents a complete set of calculated metrics for a given time period.
class ReportMetrics {
  final dynamic expense;
  final double profit;
  final YieldMetrics yield;

  final Map<AnimalType, YieldMetrics> animalBreakdown;

  const ReportMetrics({
    required this.expense,
    required this.profit,
    required this.yield,
    this.animalBreakdown = const <AnimalType, YieldMetrics>{},
  });

  /// Serializes this object to a JSON-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'expense': expense,
      'profit': profit,
      ...yield.toMap(),
      'animal_breakdown': animalBreakdown.map(
        (animalType, yieldMetrics) =>
            MapEntry(animalType.key, yieldMetrics.toMap()),
      ),
    };
  }
}

/// The top-level model for a complete report.
class Report {
  final ReportMetrics summary;
  final GroupByFrequency groupByFrequency;
  final DateTime startDate;
  final DateTime endDate;
  final List<AnimalType> animals;
  final Map<String, ReportMetrics>? dataBreakdown;

  const Report({
    required this.summary,
    required this.groupByFrequency,
    required this.startDate,
    required this.endDate,
    required this.animals,
    this.dataBreakdown,
  });

  /// Serializes the entire report into a JSON-compatible map.
  Map<String, dynamic> toMap() {
    final summaryMap = summary.toMap()
      ..addAll({
        'start_date': DateFormat('yyyy-MM-dd').format(startDate),
        'end_date': DateFormat('yyyy-MM-dd').format(endDate),
        'group_by': groupByFrequency.name,
        'animals': animals.map((e) => e.key).toList(),
      });

    final finalMap = <String, dynamic>{
      'summary': summaryMap,
    };

    if (dataBreakdown != null) {
      finalMap['data_breakdown'] = {
        '${groupByFrequency.name}_breakdown': dataBreakdown!.map(
          (key, value) => MapEntry(key, value.toMap()),
        ),
      };
    }

    return finalMap;
  }
}
