import 'package:firebase_auth/firebase_auth.dart';
import '../../models/income_model.dart';
import '../../models/report_data.dart';
import '../../constants/constants.dart';
import '../repositories/income_repository.dart';
import '../repositories/expense_repository.dart';
import '../repositories/user_repository.dart';
import '../../utils/date_utils.dart' as custom_date_utils;

/// Service for generating real reports from Firestore data
class ReportsService {
  final IncomeRepository _incomeRepo;
  final ExpenseRepository _expenseRepo;

  ReportsService({
    required IncomeRepository incomeRepo,
    required ExpenseRepository expenseRepo,
    required UserRepository userRepo,
  }) : _incomeRepo = incomeRepo,
       _expenseRepo = expenseRepo;

  /// Get current user ID
  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  /// Generate weekly reports from real data
  Future<List<ReportData>> getWeeklyReports() async {
    if (_userId == null) return [];

    try {
      final now = DateTime.now();
      final weekStart = custom_date_utils.DateUtils.getFirstDayOfWeek(now);
      final weekEnd = custom_date_utils.DateUtils.getLastDayOfWeek(now);

      // Get income data for the week
      final incomeSnapshot = await _incomeRepo.getIncomeForAnimalsInDateRange(
        _userId!,
        weekStart,
        weekEnd,
      );

      // Get expense data for the week (not used in current implementation)
      // final expenseSnapshot = await _expenseRepo.getExpensesForDateRange(
      //   _userId!,
      //   weekStart,
      //   weekEnd,
      // );

      // Process income data by day
      final Map<String, Map<AnimalType, Map<String, double>>> dailyData = {};
      
      for (final doc in incomeSnapshot.docs) {
        final data = doc.data();
        final income = IncomeModel.fromMap(data);
        final dayKey = custom_date_utils.DateUtils.formatDate(income.dateTime);
        
        if (!dailyData.containsKey(dayKey)) {
          dailyData[dayKey] = {
            AnimalType.cow: {'milk': 0.0, 'snf': 0.0, 'fat': 0.0, 'count': 0.0},
            AnimalType.buffalo: {'milk': 0.0, 'snf': 0.0, 'fat': 0.0, 'count': 0.0},
          };
        }

        // Aggregate data by animal type
        dailyData[dayKey]![income.animalType]!['milk'] = 
            (dailyData[dayKey]![income.animalType]!['milk']! + income.liters);
        dailyData[dayKey]![income.animalType]!['snf'] = 
            (dailyData[dayKey]![income.animalType]!['snf']! + income.snf);
        dailyData[dayKey]![income.animalType]!['fat'] = 
            (dailyData[dayKey]![income.animalType]!['fat']! + income.fat);
        dailyData[dayKey]![income.animalType]!['count'] = 
            (dailyData[dayKey]![income.animalType]!['count']! + 1);
      }

      // Convert to ReportData list
      final List<ReportData> reports = [];
      final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      
      for (int i = 0; i < 7; i++) {
        final dayDate = weekStart.add(Duration(days: i));
        final dayKey = custom_date_utils.DateUtils.formatDate(dayDate);
        final dayName = dayNames[i];
        
        final cowData = dailyData[dayKey]?[AnimalType.cow] ?? {'milk': 0.0, 'snf': 0.0, 'fat': 0.0, 'count': 0.0};
        final buffaloData = dailyData[dayKey]?[AnimalType.buffalo] ?? {'milk': 0.0, 'snf': 0.0, 'fat': 0.0, 'count': 0.0};

        // Calculate averages for SNF and Fat
        final cowSnfAvg = cowData['count']! > 0 ? cowData['snf']! / cowData['count']! : 0.0;
        final cowFatAvg = cowData['count']! > 0 ? cowData['fat']! / cowData['count']! : 0.0;
        final buffaloSnfAvg = buffaloData['count']! > 0 ? buffaloData['snf']! / buffaloData['count']! : 0.0;
        final buffaloFatAvg = buffaloData['count']! > 0 ? buffaloData['fat']! / buffaloData['count']! : 0.0;

        reports.add(ReportData(
          period: dayName,
          cowMilk: cowData['milk']!,
          cowSnf: cowSnfAvg,
          cowFat: cowFatAvg,
          buffaloMilk: buffaloData['milk']!,
          buffaloSnf: buffaloSnfAvg,
          buffaloFat: buffaloFatAvg,
        ));
      }

      return reports;
    } catch (e) {
      print('Error getting weekly reports: $e');
      return [];
    }
  }

  /// Generate monthly reports from real data
  Future<List<ReportData>> getMonthlyReports() async {
    if (_userId == null) return [];

    try {
      final now = DateTime.now();
      final monthStart = custom_date_utils.DateUtils.getFirstDayOfMonth(now);
      final monthEnd = custom_date_utils.DateUtils.getLastDayOfMonth(now);

      // Get income data for the month
      final incomeSnapshot = await _incomeRepo.getIncomeForAnimalsInDateRange(
        _userId!,
        monthStart,
        monthEnd,
      );

      // Process income data by week within the month
      final Map<String, Map<AnimalType, Map<String, double>>> weeklyData = {};
      
      for (final doc in incomeSnapshot.docs) {
        final data = doc.data();
        final income = IncomeModel.fromMap(data);
        
        // Calculate week number within the month (1-4)
        final dayOfMonth = income.dateTime.day;
        final weekInMonth = ((dayOfMonth - 1) ~/ 7) + 1;
        final weekKey = 'W$weekInMonth';
        
        if (!weeklyData.containsKey(weekKey)) {
          weeklyData[weekKey] = {
            AnimalType.cow: {'milk': 0.0, 'snf': 0.0, 'fat': 0.0, 'count': 0.0},
            AnimalType.buffalo: {'milk': 0.0, 'snf': 0.0, 'fat': 0.0, 'count': 0.0},
          };
        }

        // Aggregate data by animal type
        weeklyData[weekKey]![income.animalType]!['milk'] = 
            (weeklyData[weekKey]![income.animalType]!['milk']! + income.liters);
        weeklyData[weekKey]![income.animalType]!['snf'] = 
            (weeklyData[weekKey]![income.animalType]!['snf']! + income.snf);
        weeklyData[weekKey]![income.animalType]!['fat'] = 
            (weeklyData[weekKey]![income.animalType]!['fat']! + income.fat);
        weeklyData[weekKey]![income.animalType]!['count'] = 
            (weeklyData[weekKey]![income.animalType]!['count']! + 1);
      }

      // Convert to ReportData list - ensure we show all 4 weeks
      final List<ReportData> reports = [];
      
      for (int weekNum = 1; weekNum <= 4; weekNum++) {
        final weekKey = 'W$weekNum';
        final cowData = weeklyData[weekKey]?[AnimalType.cow] ?? {'milk': 0.0, 'snf': 0.0, 'fat': 0.0, 'count': 0.0};
        final buffaloData = weeklyData[weekKey]?[AnimalType.buffalo] ?? {'milk': 0.0, 'snf': 0.0, 'fat': 0.0, 'count': 0.0};

        // Calculate averages for SNF and Fat
        final cowSnfAvg = cowData['count']! > 0 ? cowData['snf']! / cowData['count']! : 0.0;
        final cowFatAvg = cowData['count']! > 0 ? cowData['fat']! / cowData['count']! : 0.0;
        final buffaloSnfAvg = buffaloData['count']! > 0 ? buffaloData['snf']! / buffaloData['count']! : 0.0;
        final buffaloFatAvg = buffaloData['count']! > 0 ? buffaloData['fat']! / buffaloData['count']! : 0.0;

        reports.add(ReportData(
          period: weekKey,
          cowMilk: cowData['milk']!,
          cowSnf: cowSnfAvg,
          cowFat: cowFatAvg,
          buffaloMilk: buffaloData['milk']!,
          buffaloSnf: buffaloSnfAvg,
          buffaloFat: buffaloFatAvg,
        ));
      }

      return reports;
    } catch (e) {
      print('Error getting monthly reports: $e');
      return [];
    }
  }

  /// Generate yearly reports from real data
  Future<List<ReportData>> getYearlyReports() async {
    if (_userId == null) return [];

    try {
      final now = DateTime.now();
      final yearStart = custom_date_utils.DateUtils.getFirstDayOfYear(now);
      final yearEnd = custom_date_utils.DateUtils.getLastDayOfYear(now);

      // Get income data for the year
      final incomeSnapshot = await _incomeRepo.getIncomeForAnimalsInDateRange(
        _userId!,
        yearStart,
        yearEnd,
      );

      // Process income data by month
      final Map<String, Map<AnimalType, Map<String, double>>> monthlyData = {};
      
      for (final doc in incomeSnapshot.docs) {
        final data = doc.data();
        final income = IncomeModel.fromMap(data);
        final monthName = custom_date_utils.DateUtils.getMonthName(income.dateTime);
        
        if (!monthlyData.containsKey(monthName)) {
          monthlyData[monthName] = {
            AnimalType.cow: {'milk': 0.0, 'snf': 0.0, 'fat': 0.0},
            AnimalType.buffalo: {'milk': 0.0, 'snf': 0.0, 'fat': 0.0},
          };
        }

        // Aggregate data by animal type
        monthlyData[monthName]![income.animalType]!['milk'] = 
            (monthlyData[monthName]![income.animalType]!['milk']! + income.liters);
        monthlyData[monthName]![income.animalType]!['snf'] = 
            (monthlyData[monthName]![income.animalType]!['snf']! + income.snf) / 2; // Average
        monthlyData[monthName]![income.animalType]!['fat'] = 
            (monthlyData[monthName]![income.animalType]!['fat']! + income.fat) / 2; // Average
      }

      // Convert to ReportData list
      final List<ReportData> reports = [];
      final monthNames = ['January', 'February', 'March', 'April', 'May', 'June',
                         'July', 'August', 'September', 'October', 'November', 'December'];
      
      for (final monthName in monthNames) {
        final cowData = monthlyData[monthName]?[AnimalType.cow] ?? {'milk': 0.0, 'snf': 0.0, 'fat': 0.0};
        final buffaloData = monthlyData[monthName]?[AnimalType.buffalo] ?? {'milk': 0.0, 'snf': 0.0, 'fat': 0.0};

        reports.add(ReportData(
          period: monthName,
          cowMilk: cowData['milk']!,
          cowSnf: cowData['snf']!,
          cowFat: cowData['fat']!,
          buffaloMilk: buffaloData['milk']!,
          buffaloSnf: buffaloData['snf']!,
          buffaloFat: buffaloData['fat']!,
        ));
      }

      return reports;
    } catch (e) {
      print('Error getting yearly reports: $e');
      return [];
    }
  }

  /// Get income summary (expenses, income, profit) for a given period
  Future<Map<String, double>> getIncomeSummary(String period) async {
    if (_userId == null) return {'expense': 0.0, 'income': 0.0, 'profit': 0.0};

    try {
      DateTime startDate, endDate;
      final now = DateTime.now();

      switch (period) {
        case 'Weekly':
          startDate = custom_date_utils.DateUtils.getFirstDayOfWeek(now);
          endDate = custom_date_utils.DateUtils.getLastDayOfWeek(now);
          break;
        case 'Monthly':
          startDate = custom_date_utils.DateUtils.getFirstDayOfMonth(now);
          endDate = custom_date_utils.DateUtils.getLastDayOfMonth(now);
          break;
        case 'Yearly':
          startDate = custom_date_utils.DateUtils.getFirstDayOfYear(now);
          endDate = custom_date_utils.DateUtils.getLastDayOfYear(now);
          break;
        default:
          startDate = custom_date_utils.DateUtils.getFirstDayOfWeek(now);
          endDate = custom_date_utils.DateUtils.getLastDayOfWeek(now);
      }

      // Get income data
      final incomeSnapshot = await _incomeRepo.getIncomeForAnimalsInDateRange(
        _userId!,
        startDate,
        endDate,
      );

      // Get expense data
      final expenseSnapshot = await _expenseRepo.getExpensesForDateRange(
        _userId!,
        startDate,
        endDate,
      );

      // Calculate totals
      double totalIncome = 0.0;
      for (final doc in incomeSnapshot.docs) {
        final data = doc.data();
        totalIncome += (data['totalIncome'] as num?)?.toDouble() ?? 0.0;
      }

      double totalExpense = 0.0;
      for (final doc in expenseSnapshot.docs) {
        final data = doc.data();
        totalExpense += (data['totalAmount'] as num?)?.toDouble() ?? 0.0;
      }

      final profit = totalIncome - totalExpense;

      return {
        'expense': totalExpense,
        'income': totalIncome,
        'profit': profit,
      };
    } catch (e) {
      print('Error getting income summary: $e');
      return {'expense': 0.0, 'income': 0.0, 'profit': 0.0};
    }
  }
}
