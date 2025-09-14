import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/reports_provider.dart';
import '../../models/report_data.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'Weekly';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReportsData();
    });
  }

  void _loadReportsData() {
    final reportsProvider = Provider.of<ReportsProvider>(context, listen: false);
    
    switch (_selectedPeriod) {
      case 'Weekly':
        final now = DateTime.now();
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        reportsProvider.fetchWeeklyReports(startOfWeek, now);
        break;
      case 'Monthly':
        final now = DateTime.now();
        reportsProvider.fetchMonthlyReports(now.month, now.year);
        break;
      case 'Yearly':
        reportsProvider.fetchYearlyReports(DateTime.now().year);
        break;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.black,
        toolbarHeight: 90,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Reports',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Icon(Icons.bar_chart, color: Colors.white, size: 32),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white, size: 28),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Consumer<ReportsProvider>(
        builder: (context, reportsProvider, child) {
          if (reportsProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ),
            );
          }

          if (reportsProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${reportsProvider.error}',
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadReportsData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  // Tabs
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Row(
                        children: [
                          _buildTabButton('Weekly', 0),
                          _buildTabButton('Monthly', 1),
                          _buildTabButton('Yearly', 2),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Main content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: TabBarView(
                        controller: _tabController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildReportContent('Select Week', 'dd/mm/yy', reportsProvider.weeklyReports, reportsProvider.weeklyIncome),
                          _buildReportContent('Month', 'dd/mm/yy', reportsProvider.monthlyReports, reportsProvider.monthlyIncome),
                          _buildReportContent('Select Year', 'dd/mm/yy', reportsProvider.yearlyReports, reportsProvider.yearlyIncome),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabButton(String label, int tabIndex) {
    final isSelected = _selectedPeriod == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPeriod = label;
            _tabController.index = tabIndex;
          });
          _loadReportsData();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.black, width: 1),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReportContent(String periodLabel, String dateLabel, List<ReportData> reports, IncomeSummary incomeSummary) {
    final List<String> weekOptions = ['W1', 'W2', 'W3', 'W4'];
    final List<String> monthOptions = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final List<String> yearOptions = ['2022', '2023', '2024', '2025'];
    
    String selectedPeriod = periodLabel == 'Select Week' 
        ? weekOptions[0] 
        : periodLabel == 'Month' 
            ? monthOptions[0] 
            : yearOptions[0];
    String selectedDate = dateLabel;
    
    return StatefulBuilder(
      builder: (context, setState) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Selectors
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedPeriod,
                            isExpanded: true,
                            isDense: true,
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                            items: (periodLabel == 'Select Week'
                                    ? weekOptions
                                    : periodLabel == 'Month'
                                        ? monthOptions
                                        : yearOptions)
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) setState(() => selectedPeriod = value);
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        child: GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setState(() => selectedDate = '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}');
                            }
                          },
                          child: Row(
                            children: [
                              Text(
                                'Date: $selectedDate',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              const Icon(Icons.calendar_today, color: Colors.black, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                // Table
                _buildReportTable(reports),
                const SizedBox(height: 18),
                // Chart placeholder
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 120,
                        child: Placeholder(), // Replace with your chart widget
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getAverageText(periodLabel, reports),
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                // Income/Expense/Profit section
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        periodLabel == 'Select Week'
                            ? 'WEEKLY INCOME'
                            : periodLabel == 'Month'
                                ? 'MONTHLY INCOME'
                                : 'YEARLY INCOME',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildIncomeRow('Expense', '${incomeSummary.expense.toStringAsFixed(0)}/-'),
                      const SizedBox(height: 8),
                      _buildIncomeRow('Income', '${incomeSummary.income.toStringAsFixed(0)}/-'),
                      const SizedBox(height: 8),
                      _buildIncomeRow('Profit', '${incomeSummary.profit.toStringAsFixed(0)}/-'),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getAverageText(String periodLabel, List<ReportData> reports) {
    if (reports.isEmpty) return 'No data available';
    
    // Calculate averages from actual data
    double totalCowMilk = reports.fold(0.0, (sum, item) => sum + item.cowMilk);
    double totalBuffaloMilk = reports.fold(0.0, (sum, item) => sum + item.buffaloMilk);
    double avgCowSnf = reports.fold(0.0, (sum, item) => sum + item.cowSnf) / reports.length;
    double avgBuffaloSnf = reports.fold(0.0, (sum, item) => sum + item.buffaloSnf) / reports.length;
    double avgCowFat = reports.fold(0.0, (sum, item) => sum + item.cowFat) / reports.length;
    double avgBuffaloFat = reports.fold(0.0, (sum, item) => sum + item.buffaloFat) / reports.length;
    
    return periodLabel == 'Select Week'
        ? 'Milk Weekly Total: ${(totalCowMilk + totalBuffaloMilk).toStringAsFixed(0)} L\nSNF Average: ${((avgCowSnf + avgBuffaloSnf) / 2).toStringAsFixed(1)}\nFat% Average: ${((avgCowFat + avgBuffaloFat) / 2).toStringAsFixed(1)}%'
        : periodLabel == 'Month'
            ? 'Milk Monthly Total: ${(totalCowMilk + totalBuffaloMilk).toStringAsFixed(0)} L\nSNF Average: ${((avgCowSnf + avgBuffaloSnf) / 2).toStringAsFixed(1)}\nFat% Average: ${((avgCowFat + avgBuffaloFat) / 2).toStringAsFixed(1)}%'
            : 'Milk Yearly Total: ${(totalCowMilk + totalBuffaloMilk).toStringAsFixed(0)} L\nSNF Average: ${((avgCowSnf + avgBuffaloSnf) / 2).toStringAsFixed(1)}\nFat% Average: ${((avgCowFat + avgBuffaloFat) / 2).toStringAsFixed(1)}%';
  }

  Widget _buildReportTable(List<ReportData> data) {
    if (data.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: const Center(
          child: Text(
            'No data available',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    final String firstColumnHeader = _selectedPeriod == 'Weekly' ? 'DAY' : _selectedPeriod == 'Monthly' ? 'Week' : 'Month';
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTableHeader(firstColumnHeader),
          ..._buildDataRows(data),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String firstColumnHeader) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(6),
          topRight: Radius.circular(6),
        ),
      ),
      child: Column(
        children: [
          // First Header Row: Period, Cow, Buffalo
          Row(
            children: [
              _buildHeaderCell(firstColumnHeader, flex: 15),
              _buildHeaderCell('Cow', flex: 30),
              _buildHeaderCell('Buffalo', flex: 30, hasRightBorder: false),
            ],
          ),
          // Horizontal separator row - only under Cow and Buffalo sections
          Row(
            children: [
              Expanded(flex: 15, child: Container()),
              Expanded(
                flex: 30,
                child: Container(
                  height: 1,
                  color: Colors.black,
                ),
              ),
              Expanded(
                flex: 30,
                child: Container(
                  height: 1,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          // Second Header Row: Sub-headers with units
          Row(
            children: [
              Expanded(flex: 15, child: Container()),
              _buildSubHeaderCell('Milk(L)', flex: 10, hasLeftBorder: true),
              _buildSubHeaderCell('SNF', flex: 10),
              _buildSubHeaderCell('Fat%', flex: 10),
              _buildSubHeaderCell('Milk(L)', flex: 10, hasLeftBorder: true),
              _buildSubHeaderCell('SNF', flex: 10),
              _buildSubHeaderCell('Fat%', flex: 10, hasRightBorder: false),
            ],
          ),
          Container(
            height: 1,
            color: Colors.black,
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, {required int flex, bool hasRightBorder = true}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            right: hasRightBorder ? const BorderSide(color: Colors.black, width: 1) : BorderSide.none,
            bottom: const BorderSide(color: Colors.black, width: 1),
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildSubHeaderCell(String text, {required int flex, bool hasLeftBorder = false, bool hasRightBorder = true}) {
    final isMilk = text == 'Milk(L)';
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            left: hasLeftBorder ? const BorderSide(color: Colors.black, width: 1) : BorderSide.none,
            right: hasRightBorder ? const BorderSide(color: Colors.black, width: 1) : BorderSide.none,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isMilk ? 9 : 11,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDataRows(List<ReportData> data) {
    List<Widget> rows = [];
    for (var i = 0; i < data.length; i++) {
      final rowData = data[i];
      rows.add(
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: (i == data.length - 1)
                  ? BorderSide.none
                  : const BorderSide(color: Colors.black, width: 1),
            ),
          ),
          child: Row(
            children: [
              _buildDataCell(rowData.period, flex: 15, isBold: true),
              _buildDataCell(rowData.cowMilk.toStringAsFixed(1), flex: 10),
              _buildDataCell(rowData.cowSnf.toStringAsFixed(1), flex: 10),
              _buildDataCell(rowData.cowFat.toStringAsFixed(1), flex: 10),
              _buildDataCell(rowData.buffaloMilk.toStringAsFixed(1), flex: 10),
              _buildDataCell(rowData.buffaloSnf.toStringAsFixed(1), flex: 10),
              _buildDataCell(rowData.buffaloFat.toStringAsFixed(1), flex: 10, hasRightBorder: false),
            ],
          ),
        ),
      );
    }
    return rows;
  }

  Widget _buildDataCell(String text, {required int flex, bool hasRightBorder = true, bool isBold = false}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            right: hasRightBorder ? const BorderSide(color: Colors.black, width: 1) : BorderSide.none,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: Colors.black,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildIncomeRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black, width: 1),
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
