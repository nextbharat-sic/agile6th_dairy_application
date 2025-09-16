import '../../constants/constants.dart';
import '../../models/expense_model.dart';
import '../../models/income_model.dart';
import '../models/report_models.dart';

/// A helper class that acts as a "calculator and container" for the data
/// of a single time group (e.g., all data for one specific day or one week).
class ReportDataAggregator {
  double _totalIncome = 0.0;
  double _totalMilk = 0.0;
  double _totalExpense = 0.0;
  final List<double> _fatValues = [];
  final List<double> _snfValues = [];
  final Map<AnimalType, ReportDataAggregator> _animalBreakdown;

  ReportDataAggregator({required List<AnimalType> animalTypes})
      : _animalBreakdown = {
    for (var type in animalTypes) type: ReportDataAggregator(animalTypes: [])
  };

  /// Adds an income record to this group and updates the totals.
  void addIncome(IncomeModel income, bool breakdown) {
    _totalIncome += income.totalIncome;
    _totalMilk += income.liters;
    _fatValues.add(income.fat);
    _snfValues.add(income.snf);

    if (breakdown) {
      _animalBreakdown[income.animalType]?.addIncome(income, false);
    }
  }

  /// Adds an expense record to this group's envelope.
  void addExpense(ExpenseModel expense) {
    _totalExpense += expense.amount;
  }

  /// Performs the final calculations for this envelope and returns a clean `ReportMetrics` object.
  ReportMetrics toReportMetrics(GroupByFrequency groupBy, bool generateBreakdown) {
    final avgFat = _fatValues.isEmpty ? 0.0 : _fatValues.reduce((a, b) => a + b) / _fatValues.length;
    final avgSnf = _snfValues.isEmpty ? 0.0 : _snfValues.reduce((a, b) => a + b) / _snfValues.length;

    // Business Rule: For daily/weekly views, showing a specific expense total isn't meaningful.
    final dynamic displayExpense =
    (groupBy == GroupByFrequency.day || groupBy == GroupByFrequency.week) ? '--' : _totalExpense;

    final double profit = _totalIncome - _totalExpense;

    return ReportMetrics(
      expense: displayExpense,
      profit: profit,
      yield: YieldMetrics(income: _totalIncome, milkQuantity: _totalMilk, avgFat: avgFat, avgSnf: avgSnf),
      animalBreakdown:
      generateBreakdown ? _animalBreakdown.map((key, value) => MapEntry(key, value.toYieldMetrics())) : {},
    );
  }

  /// A simpler calculation for the animal-specific breakdown.
  YieldMetrics toYieldMetrics() {
    final avgFat = _fatValues.isEmpty ? 0.0 : _fatValues.reduce((a, b) => a + b) / _fatValues.length;
    final avgSnf = _snfValues.isEmpty ? 0.0 : _snfValues.reduce((a, b) => a + b) / _snfValues.length;
    return YieldMetrics(income: _totalIncome, milkQuantity: _totalMilk, avgFat: avgFat, avgSnf: avgSnf);
  }
}