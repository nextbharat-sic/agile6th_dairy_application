import '../../constants/constants.dart';
import '../../models/income_model.dart';
import '../../models/expense_model.dart';
import '../../models/report_models.dart';
import '../../utils/date_utils.dart';
import '../../utils/report_aggregatory.dart';
import '../../utils/validators.dart';
import '../repositories/expense_repository.dart';
import '../repositories/income_repository.dart';

class ReportService {
  final IncomeRepository _incomeRepository;
  final ExpenseRepository _expenseRepository;

  ReportService({
    required IncomeRepository incomeRepository,
    required ExpenseRepository expenseRepository,
  })  : _incomeRepository = incomeRepository,
        _expenseRepository = expenseRepository;

  Future<Report> generateReport({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    required GroupByFrequency groupByFrequency,
    required List<AnimalType> animalTypes,
    bool generateAnimalBreakdown = false,
  }) async {
    Validator.validateDateRange(startDate: startDate, endDate: endDate);

    final normalizedStartDate = DateUtils.getStartOfDay(startDate);
    final normalizedEndDate = DateUtils.getEndOfDay(endDate);

    // STEP 1: Fetch all data.
    final rawData = await _fetchAllDataForReport(
        userId, normalizedStartDate, normalizedEndDate, animalTypes);
    final allIncomes = rawData['incomes']!;
    final allExpenses = rawData['expenses']!;

    // STEP 2: Create the report's structure (skeleton).
    final reportSkeleton = _createReportSkeleton(
        normalizedStartDate, normalizedEndDate, groupByFrequency, animalTypes);

    // STEP 3: Fill the skeleton with the fetched data.
    final populatedReportData = _populateReportData(reportSkeleton, allIncomes,
        allExpenses, groupByFrequency, generateAnimalBreakdown);

    // STEP 4: Calculate the grand total summary.
    final summaryMetrics = _calculateGrandTotalSummary(
        allIncomes, allExpenses, animalTypes, generateAnimalBreakdown);

    // STEP 5: Assemble the final, user-friendly report.
    final dataBreakdown = <String, ReportMetrics>{};
    populatedReportData.forEach((key, dataGroup) {
      final displayKey =
          DateUtils.generateDisplayKeyForGroup(key, groupByFrequency);
      dataBreakdown[displayKey] =
          dataGroup.toReportMetrics(groupByFrequency, generateAnimalBreakdown);
    });

    return Report(
      summary: summaryMetrics,
      groupByFrequency: groupByFrequency,
      startDate: normalizedStartDate,
      endDate: normalizedEndDate,
      animals: animalTypes,
      dataBreakdown: dataBreakdown,
    );
  }

  /// STEP 1: Fetches all data.
  Future<Map<String, dynamic>> _fetchAllDataForReport(
      String userId,
      DateTime startDate,
      DateTime endDate,
      List<AnimalType> animalTypes) async {
    final results = await Future.wait([
      _incomeRepository.getIncomeForAnimalsInDateRange(
        userId,
        startDate,
        endDate,
      ),
      _expenseRepository.getExpenses(userId, startDate, endDate),
    ]);
    final incomeDocs = results[0] as dynamic;
    return {
      'incomes': incomeDocs.docs
          .map<IncomeModel>((d) => IncomeModel.fromMap(d.data()))
          .toList() as List<IncomeModel>,
      'expenses': results[1] as List<ExpenseModel>,
    };
  }

  /// STEP 2: Creates the report skeleton.
  Map<String, ReportDataAggregator> _createReportSkeleton(DateTime start,
      DateTime end, GroupByFrequency groupByFrequency, List<AnimalType> types) {
    final Map<String, ReportDataAggregator> skeleton = {};
    for (var cursor = start;
        !cursor.isAfter(end);
        cursor = DateUtils.advanceDateToNextGroup(cursor, groupByFrequency)) {
      final key = DateUtils.generateGroupKeyForDate(cursor, groupByFrequency);
      skeleton.putIfAbsent(key, () => ReportDataAggregator(animalTypes: types));
    }
    return skeleton;
  }

  /// STEP 3: Fills the skeleton with data.
  Map<String, ReportDataAggregator> _populateReportData(
      Map<String, ReportDataAggregator> skeleton,
      List<IncomeModel> incomes,
      List<ExpenseModel> expenses,
      GroupByFrequency groupByFrequency,
      bool generateBreakdown) {
    for (final income in incomes) {
      final key = DateUtils.generateGroupKeyForDate(
          income.dateTime, groupByFrequency); // Uses updated DateUtils
      skeleton[key]?.addIncome(income, generateBreakdown);
    }
    for (final expense in expenses) {
      final key = DateUtils.generateGroupKeyForDate(
          expense.dateTime, groupByFrequency); // Uses updated DateUtils
      skeleton[key]?.addExpense(expense);
    }
    return skeleton;
  }

  /// STEP 4: Calculates the grand total summary.
  ReportMetrics _calculateGrandTotalSummary(List<IncomeModel> incomes,
      List<ExpenseModel> expenses, List<AnimalType> types, bool breakdown) {
    final summaryAggregator = ReportDataAggregator(animalTypes: types);
    for (final income in incomes) {
      summaryAggregator.addIncome(income, breakdown);
    }
    for (final expense in expenses) {
      summaryAggregator.addExpense(expense);
    }
    return summaryAggregator.toReportMetrics(GroupByFrequency.year, breakdown);
  }

  /// Calculates average values excluding zero/empty data points
  Future<Map<String, dynamic>> calculateAverages({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    required GroupByFrequency groupByFrequency,
    required List<AnimalType> animalTypes,
  }) async {
    final normalizedStartDate = DateUtils.getStartOfDay(startDate);
    final normalizedEndDate = DateUtils.getEndOfDay(endDate);

    // Fetch all income data
    final incomeSnapshot = await _incomeRepository.getIncomeForAnimalsInDateRange(
      userId,
      normalizedStartDate,
      normalizedEndDate,
    );

    final incomes = incomeSnapshot.docs
        .map<IncomeModel>((doc) => IncomeModel.fromMap(doc.data()))
        .toList();

    // Filter out zero values and calculate averages
    final validIncomes = incomes.where((income) => 
        income.liters > 0 && income.fat > 0 && income.snf > 0).toList();

    if (validIncomes.isEmpty) {
      return {
        'milkAverage': 0.0,
        'fatAverage': 0.0,
        'snfAverage': 0.0,
        'dataPoints': 0,
        'period': _getPeriodLabel(groupByFrequency),
      };
    }

    // Calculate averages by animal type
    final Map<AnimalType, List<IncomeModel>> incomesByAnimal = {};
    for (final animalType in animalTypes) {
      incomesByAnimal[animalType] = validIncomes
          .where((income) => income.animalType == animalType)
          .toList();
    }

    // Calculate overall averages
    final totalMilk = validIncomes.fold(0.0, (sum, income) => sum + income.liters);
    final totalFat = validIncomes.fold(0.0, (sum, income) => sum + income.fat);
    final totalSnf = validIncomes.fold(0.0, (sum, income) => sum + income.snf);
    final dataPoints = validIncomes.length;

    // Calculate averages by period (day/month)
    final Map<String, List<IncomeModel>> periodData = {};
    for (final income in validIncomes) {
      final key = DateUtils.generateGroupKeyForDate(income.dateTime, groupByFrequency);
      periodData.putIfAbsent(key, () => []).add(income);
    }

    // Calculate period averages (excluding periods with no data)
    final periodAverages = <String, Map<String, double>>{};
    periodData.forEach((period, periodIncomes) {
      if (periodIncomes.isNotEmpty) {
        final periodMilk = periodIncomes.fold(0.0, (sum, income) => sum + income.liters);
        final periodFat = periodIncomes.fold(0.0, (sum, income) => sum + income.fat);
        final periodSnf = periodIncomes.fold(0.0, (sum, income) => sum + income.snf);
        
        periodAverages[period] = {
          'milk': periodMilk,
          'fat': periodFat / periodIncomes.length,
          'snf': periodSnf / periodIncomes.length,
        };
      }
    });

    return {
      'milkAverage': totalMilk / dataPoints,
      'fatAverage': totalFat / dataPoints,
      'snfAverage': totalSnf / dataPoints,
      'dataPoints': dataPoints,
      'period': _getPeriodLabel(groupByFrequency),
      'periodAverages': periodAverages,
      'animalBreakdown': _calculateAnimalAverages(incomesByAnimal),
    };
  }

  /// Calculate averages by animal type
  Map<AnimalType, Map<String, double>> _calculateAnimalAverages(
      Map<AnimalType, List<IncomeModel>> incomesByAnimal) {
    final Map<AnimalType, Map<String, double>> result = {};
    
    incomesByAnimal.forEach((animalType, incomes) {
      if (incomes.isNotEmpty) {
        final totalMilk = incomes.fold(0.0, (sum, income) => sum + income.liters);
        final totalFat = incomes.fold(0.0, (sum, income) => sum + income.fat);
        final totalSnf = incomes.fold(0.0, (sum, income) => sum + income.snf);
        
        result[animalType] = {
          'milk': totalMilk / incomes.length,
          'fat': totalFat / incomes.length,
          'snf': totalSnf / incomes.length,
        };
      }
    });
    
    return result;
  }

  /// Get period label for display
  String _getPeriodLabel(GroupByFrequency frequency) {
    switch (frequency) {
      case GroupByFrequency.day:
        return 'Daily';
      case GroupByFrequency.week:
        return 'Weekly';
      case GroupByFrequency.month:
        return 'Monthly';
      case GroupByFrequency.year:
        return 'Yearly';
      case GroupByFrequency.quarter:
        return 'Quarterly';
    }
  }
}
