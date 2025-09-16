import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

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
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return const SizedBox.shrink();
    
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
            Text(
              l10n.reports,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Icon(Icons.bar_chart, color: Colors.white, size: 32),
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
      body: SafeArea(
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
                      _buildTabButton(l10n.weekly, 0),
                      _buildTabButton(l10n.monthly, 1),
                      _buildTabButton(l10n.yearly, 2),
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
                      _buildReportContent(l10n.selectWeek, 'dd/mm/yy', l10n),
                      _buildReportContent(l10n.monthly, 'dd/mm/yy', l10n),
                      _buildReportContent(l10n.yearly, 'dd/mm/yy', l10n),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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

  Widget _buildReportContent(String periodLabel, String dateLabel, AppLocalizations l10n) {
    final List<String> weekOptions = ['W1', 'W2', 'W3', 'W4'];
    final List<String> monthOptions = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final List<String> yearOptions = ['2022', '2023', '2024'];
    String selectedPeriod = periodLabel == 'Select Week' ? weekOptions[0] : periodLabel == 'Month' ? monthOptions[0] : yearOptions[0];
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
                _buildReportTable(periodLabel),
                const SizedBox(height: 18),
                // Chart
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
                      SizedBox(
                        height: 120,
                        child: Placeholder(), // Replace with your chart widget
                      ),
                      const SizedBox(height: 8),
                      Text(
                        periodLabel == 'Select Week'
                            ? 'Milk Weekly Average : 148 L\nSNF Weekly Average : 12\nFat% Weekly Average : 20%'
                            : periodLabel == 'Month'
                                ? 'Milk Monthly Average : 520 L\nSNF Monthly Average : 20\nFat% Monthly Average : 20%'
                                : l10n.milkYearlyAverage,
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
                            ? l10n.weeklyIncome
                            : periodLabel == 'Month'
                                ? l10n.monthlyIncome
                                : l10n.yearlyIncome,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildIncomeRow(l10n.expenseHeader, '1234/-'),
                      const SizedBox(height: 8),
                      _buildIncomeRow(l10n.incomeHeader, '1234/-'),
                      const SizedBox(height: 8),
                      _buildIncomeRow(l10n.profitHeader, '1234/-'),
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

  Widget _buildReportTable(String periodLabel) {
    final isWeek = periodLabel == 'Select Week';
    final isMonth = periodLabel == 'Month';
    final isYear = periodLabel == 'Select Year';
    final String firstColumnHeader = isWeek ? 'DAY' : isMonth ? 'Week' : 'Month';
    final List<Map<String, dynamic>> data = isWeek
        ? [
            {'period': 'Mon', 'values': [20, 20, 20, 20, 20, 20]},
            {'period': 'Tue', 'values': [23, 23, 23, 23, 23, 23]},
            {'period': 'Wed', 'values': [25, 25, 25, 25, 25, 25]},
            {'period': 'Thu', 'values': [19, 19, 19, 19, 19, 19]},
            {'period': 'Fri', 'values': [24, 24, 24, 24, 24, 24]},
            {'period': 'Sat', 'values': [22, 22, 22, 22, 22, 22]},
            {'period': 'Sun', 'values': [20, 20, 20, 20, 20, 20]},
          ]
        : isMonth
            ? [
                {'period': 'W1', 'values': [20, 20, 20, 20, 20, 20]},
                {'period': 'W2', 'values': [23, 23, 23, 23, 23, 23]},
                {'period': 'W3', 'values': [25, 25, 25, 25, 25, 25]},
                {'period': 'W4', 'values': [19, 19, 19, 19, 19, 19]},
              ]
            : [
                {'period': 'Jan', 'values': [20, 20, 20, 20, 20, 20]},
                {'period': 'Feb', 'values': [23, 23, 23, 23, 23, 23]},
                {'period': 'Mar', 'values': [25, 25, 25, 25, 25, 25]},
                {'period': 'Apr', 'values': [19, 19, 19, 19, 19, 19]},
                {'period': 'May', 'values': [20, 20, 20, 20, 20, 20]},
                {'period': 'Jun', 'values': [23, 23, 23, 23, 23, 23]},
                {'period': 'Jul', 'values': [25, 25, 25, 25, 25, 25]},
                {'period': 'Aug', 'values': [19, 19, 19, 19, 19, 19]},
                {'period': 'Sep', 'values': [20, 20, 20, 20, 20, 20]},
                {'period': 'Oct', 'values': [23, 23, 23, 23, 23, 23]},
                {'period': 'Nov', 'values': [25, 25, 25, 25, 25, 25]},
                {'period': 'Dec', 'values': [19, 19, 19, 19, 19, 19]},
              ];
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
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
              fontSize: isMilk ? 9 : 11, // Reduce only for Milk(L)
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDataRows(List<Map<String, dynamic>> data) {
    List<Widget> rows = [];
    for (var i = 0; i < data.length; i++) {
      final rowData = data[i];
      final values = rowData['values'] as List;
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
              _buildDataCell((rowData['period'] as String), flex: 15, isBold: true),
              _buildDataCell(values[0].toString(), flex: 10),
              _buildDataCell(values[1].toString(), flex: 10),
              _buildDataCell(values[2].toString(), flex: 10),
              _buildDataCell(values[3].toString(), flex: 10),
              _buildDataCell(values[4].toString(), flex: 10),
              _buildDataCell(values[5].toString(), flex: 10, hasRightBorder: false),
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
