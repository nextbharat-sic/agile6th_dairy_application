import 'package:flutter/material.dart';
import '../backend/services/reports_service.dart';
import '../models/report_data.dart';

class ReportsProvider extends ChangeNotifier {
  final ReportsService _reportsService;

  ReportsProvider(this._reportsService);

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
      _weeklyReports = await _reportsService.getWeeklyReports();
      final incomeData = await _reportsService.getIncomeSummary('Weekly');
      _weeklyIncome = IncomeSummary(
        expense: incomeData['expense']!,
        income: incomeData['income']!,
        profit: incomeData['profit']!,
      );
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
      _monthlyReports = await _reportsService.getMonthlyReports();
      final incomeData = await _reportsService.getIncomeSummary('Monthly');
      _monthlyIncome = IncomeSummary(
        expense: incomeData['expense']!,
        income: incomeData['income']!,
        profit: incomeData['profit']!,
      );
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
      _yearlyReports = await _reportsService.getYearlyReports();
      final incomeData = await _reportsService.getIncomeSummary('Yearly');
      _yearlyIncome = IncomeSummary(
        expense: incomeData['expense']!,
        income: incomeData['income']!,
        profit: incomeData['profit']!,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      _yearlyReports = [];
    }
    _setLoading(false);
  }

}
