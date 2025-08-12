import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

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
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Top background (selector/header area)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
              child: Container(
                height: 220,
                width: double.infinity,
                color: const Color(0xFF395364), // #395364
              ),
            ),
            // Main background with rounded top corners
            Positioned(
              top: 180,
              left: 0,
              right: 0,
              bottom: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                child: Container(
                  color: const Color(0xFFDEE4E8), // #DEE4E8
                ),
              ),
            ),
            // Main content
            Align(
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  const SizedBox(height: 40), // reduced from 60 to move logo up by 20px
                  // Reports logo in a white circle with shadow, with 'Reports' text inside
                  Material(
                    elevation: 6,
                    shape: const CircleBorder(),
                    color: Colors.white,
                    child: Container(
                      width: 120,
                      height: 120,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/reports.png',
                            height: 54,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Reports',
                            style: TextStyle(
                              color: Color(0xFF395364),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30), // increased from 20 to move selector bar down by 10px
                  // Selector tabs
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFD6D6D6),
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
                  const SizedBox(height: 20),
                  // Reports card section
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE4E5E6), // #E4E5E6
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildReportContent('Select Week', 'dd/mm/yy'),
                            _buildReportContent('Month', 'dd/mm/yy'),
                            _buildReportContent('Select Year', 'dd/mm/yy'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodButton(String label, int tabIndex) {
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
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : AppTheme.cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : AppTheme.cardColor,
              width: 1.5,
            ),
          ),
          child: Center(
          child: Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.whiteColor : AppTheme.textPrimaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
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
          padding: const EdgeInsets.symmetric(vertical: 4), // reduced from 6 to match date selector button size
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF395364) : Colors.transparent,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF395364),
                fontWeight: FontWeight.bold,
                fontSize: 12, // keeping font size the same
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyReport() {
    return _buildReportContent('Select Week', 'dd/mm/yy');
  }

  Widget _buildMonthlyReport() {
    return _buildReportContent('Month', 'dd/mm/yy');
  }

  Widget _buildYearlyReport() {
    return _buildReportContent('Select Year', 'dd/mm/yy');
  }

  Widget _buildReportContent(String periodLabel, String dateLabel) {
    // State for selectors
    final List<String> weekOptions = ['W1', 'W2', 'W3', 'W4'];
    final List<String> monthOptions = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final List<String> yearOptions = ['2022', '2023', '2024'];
    String selectedPeriod = periodLabel == 'Select Week' ? weekOptions[0] : periodLabel == 'Month' ? monthOptions[0] : yearOptions[0];
    String selectedDate = dateLabel;
    return StatefulBuilder(
      builder: (context, setState) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Period and date selectors
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD6D6D6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedPeriod,
                          isExpanded: true,
                          isDense: true,
                          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF395364)),
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
                                  color: Color(0xFF395364),
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
                        color: const Color(0xFFD6D6D6),
                        borderRadius: BorderRadius.circular(12),
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
                                color: Color(0xFF395364),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.calendar_today, color: Color(0xFF395364), size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Table section
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBDFEB), // #CBDFEB
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(12),
                child: _buildReportTable(periodLabel),
              ),
              const SizedBox(height: 20),
              // Chart section
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    SizedBox(
                      height: 120,
                      child: CustomPaint(
                        size: const Size(double.infinity, double.infinity),
                        painter: SimpleChartPainter(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      periodLabel == 'Select Week'
                          ? 'Milk Weekly Average: 148 L\nSNF Weekly Average: 12\nFat% Weekly Average: 20%'
                          : periodLabel == 'Month'
                              ? 'Milk Monthly Average: 520 L\nSNF Monthly Average: 20\nFat% Monthly Average: 20%'
                              : 'Milk Yearly Average: 6000 L\nSNF Yearly Average: 20\nFat% Yearly Average: 20%',
                      style: const TextStyle(
                        color: Color(0xFF395364),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
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
                          ? 'Weekly Income'
                          : periodLabel == 'Month'
                              ? 'Monthly Income'
                              : 'Yearly Income',
                      style: const TextStyle(
                        color: Color(0xFF395364),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildIncomeRow('Expense', '1234/-'),
                    const SizedBox(height: 8),
                    _buildIncomeRow('Income', '1234/-'),
                    const SizedBox(height: 8),
                    _buildIncomeRow('Profit', '1234/-'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCalendarGrid() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dates = ['16', '17', '18', '19', '20', '21', '22'];
    
    return Column(
        children: [
        // Day headers
        Row(
          children: days.map((day) => Expanded(
            child: Text(
              day,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          )).toList(),
        ),
        const SizedBox(height: 8),
        // Date grid
        Row(
          children: dates.asMap().entries.map((entry) {
            final index = entry.key;
            final date = entry.value;
            final isToday = date == '20'; // Mock today's date
            final isEven = index % 2 == 0;
            return Expanded(
              child: Container(
                margin: const EdgeInsets.all(2),
                height: 40,
                decoration: BoxDecoration(
                  color: isToday
                      ? AppTheme.primaryColor
                      : isEven
                          ? AppTheme.cardColor.withValues(alpha: 0.5)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isToday ? AppTheme.primaryColor : AppTheme.textSecondaryColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Center(
                  child: Text(
                    date,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isToday ? AppTheme.whiteColor : AppTheme.textPrimaryColor,
                      fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Replace the complex _buildReportTable with a proper table implementation
  Widget _buildReportTable(String periodLabel) {
    final isWeek = periodLabel == 'Select Week';
    final isMonth = periodLabel == 'Month';
    final isYear = periodLabel == 'Select Year';
    
    // Determine the first column header
    final String firstColumnHeader = isWeek ? 'DAY' : isMonth ? 'Week' : 'Month';
    
    // Sample data based on period type
    final List<Map<String, dynamic>> data = isWeek
        ? [
            {'period': 'Mon', 'values': [20, 3.5, 4.2, 6, 8, 4.5]},
            {'period': 'Tue', 'values': [23, 3.8, 4.1, 25, 4.2, 5.2]},
            {'period': 'Wed', 'values': [25, 3.7, 4.0, 27, 4.1, 5.1]},
            {'period': 'Thu', 'values': [19, 3.6, 3.9, 20, 3.9, 4.9]},
            {'period': 'Fri', 'values': [24, 3.9, 4.2, 26, 4.3, 5.3]},
            {'period': 'Sat', 'values': [22, 3.7, 4.0, 24, 4.1, 5.1]},
            {'period': 'Sun', 'values': [20, 3.5, 4.0, 22, 4.0, 5.0]},
          ]
        : isMonth
            ? [
                {'period': 'W1', 'values': [20, 3.5, 4.0, 22, 4.0, 5.0]},
                {'period': 'W2', 'values': [23, 3.8, 4.1, 25, 4.2, 5.2]},
                {'period': 'W3', 'values': [25, 3.7, 4.0, 27, 4.1, 5.1]},
                {'period': 'W4', 'values': [19, 3.6, 3.9, 20, 3.9, 4.9]},
              ]
            : [
                {'period': 'Jan', 'values': [20, 3.5, 4.0, 22, 4.0, 5.0]},
                {'period': 'Feb', 'values': [23, 3.8, 4.1, 25, 4.2, 5.2]},
                {'period': 'Mar', 'values': [25, 3.7, 4.0, 27, 4.1, 5.1]},
                {'period': 'Apr', 'values': [19, 3.6, 3.9, 20, 3.9, 4.9]},
                {'period': 'May', 'values': [20, 3.5, 4.0, 22, 4.0, 5.0]},
                {'period': 'Jun', 'values': [23, 3.8, 4.1, 25, 4.2, 5.2]},
                {'period': 'Jul', 'values': [25, 3.7, 4.0, 27, 4.1, 5.1]},
                {'period': 'Aug', 'values': [19, 3.6, 3.9, 20, 3.9, 4.9]},
                {'period': 'Sep', 'values': [20, 3.5, 4.0, 22, 4.0, 5.0]},
                {'period': 'Oct', 'values': [23, 3.8, 4.1, 25, 4.2, 5.2]},
                {'period': 'Nov', 'values': [25, 3.7, 4.0, 27, 4.1, 5.1]},
                {'period': 'Dec', 'values': [19, 3.6, 3.9, 20, 3.9, 4.9]},
              ];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1), // changed from 2 to 1
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

  /// Builds the complex two-level header.
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
              // Period Header - White background, no bottom border
              _buildHeaderCell(firstColumnHeader, flex: 15, backgroundColor: Colors.white, hasBottomBorder: false),
              // Cow Header (Spans 3 columns)
              _buildHeaderCell('Cow', flex: 30, backgroundColor: Colors.white, hasBottomBorder: false),
              // Buffalo Header (Spans 3 columns)
              _buildHeaderCell('Buffalo', flex: 30, backgroundColor: Colors.white, hasRightBorder: false, hasBottomBorder: false),
            ],
          ),
          // Horizontal separator row - only under Cow and Buffalo sections
          Row(
            children: [
              // Empty space for first column (no line)
              Expanded(flex: 15, child: Container()),
              // Line under Cow section
              Expanded(
                flex: 30,
                child: Container(
                  height: 1,
                  color: Colors.black,
                ),
              ),
              // Line under Buffalo section
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
              // Empty space for first column
              Expanded(flex: 15, child: Container()),
              // Cow Sub-headers
              _buildSubHeaderCell('Milk', flex: 10, backgroundColor: Colors.white, hasLeftBorder: true),
              _buildSubHeaderCell('SNF', flex: 10, backgroundColor: Colors.white),
              _buildSubHeaderCell('Fat', flex: 10, backgroundColor: Colors.white),
              // Buffalo Sub-headers
              _buildSubHeaderCell('Milk', flex: 10, backgroundColor: Colors.white, hasLeftBorder: true),
              _buildSubHeaderCell('SNF', flex: 10, backgroundColor: Colors.white),
              _buildSubHeaderCell('Fat', flex: 10, backgroundColor: Colors.white, hasRightBorder: false),
            ],
          ),
          // Brackets row under subheaders
          Row(
            children: [
              // Empty space for first column
              Expanded(flex: 15, child: Container()),
              // Cow brackets
              _buildBracketCell('(L)', flex: 10, backgroundColor: Colors.white, hasLeftBorder: true),
              _buildBracketCell('(%)', flex: 10, backgroundColor: Colors.white),
              _buildBracketCell('(%)', flex: 10, backgroundColor: Colors.white),
              // Buffalo brackets
              _buildBracketCell('(L)', flex: 10, backgroundColor: Colors.white, hasLeftBorder: true),
              _buildBracketCell('(%)', flex: 10, backgroundColor: Colors.white),
              _buildBracketCell('(%)', flex: 10, backgroundColor: Colors.white, hasRightBorder: false),
            ],
          ),
          // Horizontal separator between subheaders and data
          Container(
            height: 1,
            color: Colors.black,
          ),
        ],
      ),
    );
  }

  /// Builds a single cell for the main header row.
  Widget _buildHeaderCell(String text, {required int flex, Color backgroundColor = Colors.grey, bool hasRightBorder = true, bool hasBottomBorder = true}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12), // increased to accommodate merged cell height
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border(
            right: hasRightBorder
                ? const BorderSide(color: Colors.black, width: 1) // changed from 2 to 1
                : BorderSide.none,
            bottom: hasBottomBorder
                ? const BorderSide(color: Colors.black, width: 1)
                : BorderSide.none,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11, // reduced from 12
              color: Color(0xFF395364),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  /// Builds a single cell for the sub-header row.
  Widget _buildSubHeaderCell(String text, {required int flex, required Color backgroundColor, bool hasLeftBorder = false, bool hasRightBorder = true}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.all(4), // reduced from 6
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border(
            left: hasLeftBorder ? BorderSide(color: Colors.black, width: 1) : BorderSide.none,
            right: hasRightBorder
                ? BorderSide(color: Colors.black, width: 1)
                : BorderSide.none,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 10, // reduced from 12
              color: Color(0xFF395364),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a single cell for the bracket row.
  Widget _buildBracketCell(String text, {required int flex, required Color backgroundColor, bool hasLeftBorder = false, bool hasRightBorder = true}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border(
            left: hasLeftBorder ? BorderSide(color: Colors.black, width: 1) : BorderSide.none,
            right: hasRightBorder
                ? BorderSide(color: Colors.black, width: 1)
                : BorderSide.none,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 10,
              color: Color(0xFF395364),
            ),
          ),
        ),
      ),
    );
  }

  /// Generates the list of data rows.
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
              _buildDataCell((rowData['period'] as String), flex: 15, backgroundColor: Colors.white, isBold: true),
              _buildDataCell(values[0].toString(), flex: 10, backgroundColor: Color(0xFFCBDFEB)), // Cow Milk
              _buildDataCell(values[1].toString(), flex: 10, backgroundColor: Color(0xFFCBDFEB)), // Cow SNF
              _buildDataCell(values[2].toString(), flex: 10, backgroundColor: Color(0xFFCBDFEB)), // Cow Fat
              _buildDataCell(values[3].toString(), flex: 10, backgroundColor: Color(0xFFD6D6D6)), // Buffalo Milk
              _buildDataCell(values[4].toString(), flex: 10, backgroundColor: Color(0xFFD6D6D6)), // Buffalo SNF
              _buildDataCell(values[5].toString(), flex: 10, backgroundColor: Color(0xFFD6D6D6), hasRightBorder: false), // Buffalo Fat
            ],
          ),
        ),
      );
    }
    return rows;
  }

  /// Builds a single cell for a data row.
  Widget _buildDataCell(String text, {required int flex, required Color backgroundColor, bool hasRightBorder = true, bool isBold = false}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.all(6), // reduced from 8
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border(
            right: hasRightBorder
                ? BorderSide(color: Colors.black, width: 1)
                : BorderSide.none,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 10, // reduced from 11
              color: const Color(0xFF395364),
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _tableCell(String text, {Color color = Colors.white, Alignment align = Alignment.center, bool bold = false, double fontSize = 14, bool borderBottom = false, bool borderRight = false}) {
    return Container(
      alignment: align,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color,
        border: Border(
          bottom: borderBottom ? const BorderSide(color: Colors.black, width: 2) : BorderSide.none,
          right: borderRight ? const BorderSide(color: Colors.black, width: 2) : BorderSide.none,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: const Color(0xFF395364),
          fontWeight: bold ? FontWeight.bold : FontWeight.w500,
          fontSize: fontSize,
        ),
        textAlign: TextAlign.center,
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
            color: Color(0xFF395364),
            fontWeight: FontWeight.w600,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFD6D6D6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF395364),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

// Simple chart painter
class SimpleChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = AppTheme.primaryColor.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();
    
    final points = [
      Offset(0, size.height * 0.8),
      Offset(size.width * 0.15, size.height * 0.6),
      Offset(size.width * 0.3, size.height * 0.4),
      Offset(size.width * 0.45, size.height * 0.7),
      Offset(size.width * 0.6, size.height * 0.3),
      Offset(size.width * 0.75, size.height * 0.5),
      Offset(size.width, size.height * 0.2),
    ];

    // Draw line
    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    // Draw fill
    fillPath.addPath(path, Offset.zero);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Draw points
    final pointPaint = Paint()
      ..color = AppTheme.primaryColor
      ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(point, 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
