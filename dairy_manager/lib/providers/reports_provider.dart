import 'package:flutter/material.dart';
import '../backend/services/income_service.dart';
import '../models/report_data.dart';

class ReportsProvider extends ChangeNotifier {
  final IncomeService _incomeService;

  ReportsProvider(this._incomeService);

  // State variables
  List<ReportData> _weeklyReports = [];
  List<ReportData> _monthlyReports = [];
  List<ReportData> _yearlyReports = [];
  
  IncomeSummary _weeklyIncome = IncomeSummary(expense: 0, income: 0, profit: 0);
  IncomeSummary _monthlyIncome = IncomeSummary(expense: 0, income: 0, profit: 0);
  IncomeSummary _yearlyIncome = IncomeSummary(expense: 0, income: 0, profit: 0);
  
  bool _isLoading = false;
  String? _error;

  // Getters
  List<ReportData> get weeklyReports => _weeklyReports;
  List<ReportData> get monthlyReports => _monthlyReports;
  List<ReportData> get yearlyReports => _yearlyReports;
  
  IncomeSummary get weeklyIncome => _weeklyIncome;
  IncomeSummary get monthlyIncome => _monthlyIncome;
  IncomeSummary get yearlyIncome => _yearlyIncome;
  
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Fetch weekly reports
  Future<void> fetchWeeklyReports(DateTime startDate, DateTime endDate) async {
    _setLoading(true);
    try {
      // Replace with actual backend call
      _weeklyReports = await _getWeeklyReportsFromBackend(startDate, endDate);
      _weeklyIncome = await _getWeeklyIncomeFromBackend(startDate, endDate);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _weeklyReports = [];
    }
    _setLoading(false);
  }

  // Fetch monthly reports
  Future<void> fetchMonthlyReports(int month, int year) async {
    _setLoading(true);
    try {
      // Replace with actual backend call
      _monthlyReports = await _getMonthlyReportsFromBackend(month, year);
      _monthlyIncome = await _getMonthlyIncomeFromBackend(month, year);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _monthlyReports = [];
    }
    _setLoading(false);
  }

  // Fetch yearly reports
  Future<void> fetchYearlyReports(int year) async {
    _setLoading(true);
    try {
      // Replace with actual backend call
      _yearlyReports = await _getYearlyReportsFromBackend(year);
      _yearlyIncome = await _getYearlyIncomeFromBackend(year);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _yearlyReports = [];
    }
    _setLoading(false);
  }

  // Placeholder methods - replace with actual backend calls
  Future<List<ReportData>> _getWeeklyReportsFromBackend(DateTime start, DateTime end) async {
    // TODO: Implement actual backend call using _incomeService
    await Future.delayed(const Duration(seconds: 1)); // Simulate API call
    return [
      ReportData(period: 'Mon', cowMilk: 20, cowSnf: 20, cowFat: 20, buffaloMilk: 20, buffaloSnf: 20, buffaloFat: 20),
      ReportData(period: 'Tue', cowMilk: 23, cowSnf: 23, cowFat: 23, buffaloMilk: 23, buffaloSnf: 23, buffaloFat: 23),
      ReportData(period: 'Wed', cowMilk: 25, cowSnf: 25, cowFat: 25, buffaloMilk: 25, buffaloSnf: 25, buffaloFat: 25),
      ReportData(period: 'Thu', cowMilk: 19, cowSnf: 19, cowFat: 19, buffaloMilk: 19, buffaloSnf: 19, buffaloFat: 19),
      ReportData(period: 'Fri', cowMilk: 24, cowSnf: 24, cowFat: 24, buffaloMilk: 24, buffaloSnf: 24, buffaloFat: 24),
      ReportData(period: 'Sat', cowMilk: 22, cowSnf: 22, cowFat: 22, buffaloMilk: 22, buffaloSnf: 22, buffaloFat: 22),
      ReportData(period: 'Sun', cowMilk: 20, cowSnf: 20, cowFat: 20, buffaloMilk: 20, buffaloSnf: 20, buffaloFat: 20),
    ];
  }

  Future<List<ReportData>> _getMonthlyReportsFromBackend(int month, int year) async {
    // TODO: Implement actual backend call
    await Future.delayed(const Duration(seconds: 1));
    return [
      ReportData(period: 'W1', cowMilk: 20, cowSnf: 20, cowFat: 20, buffaloMilk: 20, buffaloSnf: 20, buffaloFat: 20),
      ReportData(period: 'W2', cowMilk: 23, cowSnf: 23, cowFat: 23, buffaloMilk: 23, buffaloSnf: 23, buffaloFat: 23),
      ReportData(period: 'W3', cowMilk: 25, cowSnf: 25, cowFat: 25, buffaloMilk: 25, buffaloSnf: 25, buffaloFat: 25),
      ReportData(period: 'W4', cowMilk: 19, cowSnf: 19, cowFat: 19, buffaloMilk: 19, buffaloSnf: 19, buffaloFat: 19),
    ];
  }

  Future<List<ReportData>> _getYearlyReportsFromBackend(int year) async {
    // TODO: Implement actual backend call
    await Future.delayed(const Duration(seconds: 1));
    return [
      ReportData(period: 'Jan', cowMilk: 20, cowSnf: 20, cowFat: 20, buffaloMilk: 20, buffaloSnf: 20, buffaloFat: 20),
      ReportData(period: 'Feb', cowMilk: 23, cowSnf: 23, cowFat: 23, buffaloMilk: 23, buffaloSnf: 23, buffaloFat: 23),
      ReportData(period: 'Mar', cowMilk: 25, cowSnf: 25, cowFat: 25, buffaloMilk: 25, buffaloSnf: 25, buffaloFat: 25),
      ReportData(period: 'Apr', cowMilk: 19, cowSnf: 19, cowFat: 19, buffaloMilk: 19, buffaloSnf: 19, buffaloFat: 19),
      ReportData(period: 'May', cowMilk: 20, cowSnf: 20, cowFat: 20, buffaloMilk: 20, buffaloSnf: 20, buffaloFat: 20),
      ReportData(period: 'Jun', cowMilk: 23, cowSnf: 23, cowFat: 23, buffaloMilk: 23, buffaloSnf: 23, buffaloFat: 23),
      ReportData(period: 'Jul', cowMilk: 25, cowSnf: 25, cowFat: 25, buffaloMilk: 25, buffaloSnf: 25, buffaloFat: 25),
      ReportData(period: 'Aug', cowMilk: 19, cowSnf: 19, cowFat: 19, buffaloMilk: 19, buffaloSnf: 19, buffaloFat: 19),
      ReportData(period: 'Sep', cowMilk: 20, cowSnf: 20, cowFat: 20, buffaloMilk: 20, buffaloSnf: 20, buffaloFat: 20),
      ReportData(period: 'Oct', cowMilk: 23, cowSnf: 23, cowFat: 23, buffaloMilk: 23, buffaloSnf: 23, buffaloFat: 23),
      ReportData(period: 'Nov', cowMilk: 25, cowSnf: 25, cowFat: 25, buffaloMilk: 25, buffaloSnf: 25, buffaloFat: 25),
      ReportData(period: 'Dec', cowMilk: 19, cowSnf: 19, cowFat: 19, buffaloMilk: 19, buffaloSnf: 19, buffaloFat: 19),
    ];
  }

  Future<IncomeSummary> _getWeeklyIncomeFromBackend(DateTime start, DateTime end) async {
    // TODO: Implement actual backend call
    await Future.delayed(const Duration(milliseconds: 500));
    return IncomeSummary(expense: 1234, income: 2468, profit: 1234);
  }

  Future<IncomeSummary> _getMonthlyIncomeFromBackend(int month, int year) async {
    // TODO: Implement actual backend call
    await Future.delayed(const Duration(milliseconds: 500));
    return IncomeSummary(expense: 5234, income: 8468, profit: 3234);
  }

  Future<IncomeSummary> _getYearlyIncomeFromBackend(int year) async {
    // TODO: Implement actual backend call
    await Future.delayed(const Duration(milliseconds: 500));
    return IncomeSummary(expense: 52340, income: 84680, profit: 32340);
  }
}
