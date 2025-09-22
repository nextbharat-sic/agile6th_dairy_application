import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../backend/repositories/expense_repository.dart';
import '../../backend/repositories/income_repository.dart';
import '../../backend/services/report_service.dart';
import '../../constants/constants.dart';
import '../../models/report_models.dart';
import '../../l10n/app_localizations.dart';
import 'package:fl_chart/fl_chart.dart';

// Notification classes for scale events
class ScaleStartNotification extends Notification {}
class ScaleEndNotification extends Notification {}

// Custom ZoomableWidget for pinch zoom functionality
class ZoomableWidget extends StatefulWidget {
  final Widget child;
  final double minScale;
  final double maxScale;

  const ZoomableWidget({
    super.key,
    required this.child,
    this.minScale = 1.0,
    this.maxScale = 4.0,
  });

  @override
  State<ZoomableWidget> createState() => _ZoomableWidgetState();
}

class _ZoomableWidgetState extends State<ZoomableWidget> {
  double _scale = 1.0;
  double _previousScale = 1.0;
  Offset _offset = Offset.zero;
  Offset _previousOffset = Offset.zero;
  Offset? _initialFocalPoint;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: (details) {
        _previousScale = _scale;
        _previousOffset = _offset;
        _initialFocalPoint = details.focalPoint;
        ScaleStartNotification().dispatch(context);
      },
      onScaleUpdate: (details) {
        setState(() {
          _scale = (_previousScale * details.scale)
              .clamp(widget.minScale, widget.maxScale);
          
          if (_initialFocalPoint != null) {
            final Offset normalizedOffset = (details.focalPoint - _initialFocalPoint!) / _previousScale;
            _offset = _previousOffset + normalizedOffset;
          }
        });
      },
      onScaleEnd: (details) {
        _previousScale = _scale;
        _previousOffset = _offset;
        _initialFocalPoint = null;
        ScaleEndNotification().dispatch(context);
      },
      onDoubleTap: () {
        setState(() {
          _scale = widget.minScale;
          _offset = Offset.zero;
        });
      },
      child: Transform.scale(
        scale: _scale,
        child: Transform.translate(
          offset: _offset,
          child: widget.child,
        ),
      ),
    );
  }
}

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isTableZooming = false;

  late final ReportService _reportService;
  String? _userId;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  Report? _report;
  
  // UI selections - Initialize with current date
  int _selectedMonthIndex = DateTime.now().month - 1; // 0..11
  int _selectedYear = DateTime.now().year;
  
  // Track current tab explicitly - FIXED
  int _currentTabIndex = 0; // 0 = Monthly, 1 = Yearly
  
  // Average data
  Map<String, dynamic>? _averageData;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _incomeSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _expenseSub;

  @override
  void initState() {
    super.initState();
    
    // Initialize tab controller first
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);

    final firestore = FirebaseFirestore.instance;
    final incomeRepo = IncomeRepository(firestore);
    final expenseRepo = ExpenseRepository(firestore);
    _reportService = ReportService(
      incomeRepository: incomeRepo,
      expenseRepository: expenseRepo,
    );

    // Initialize after widget is built to access localization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentMonthReport();
      _setupRealtimeListeners();
    });
  }

  // Load current month's report as default - FIXED with proper state reset
  void _loadCurrentMonthReport() {
    final now = DateTime.now();
    setState(() {
      _selectedMonthIndex = now.month - 1; // Reset to current month
      _currentTabIndex = 0; // Set to monthly tab
      _report = null; // Clear previous report data
    });
    
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);
    final actualEnd = now.isBefore(monthEnd) ? now : monthEnd;
    _refetchWithRange(monthStart, actualEnd, GroupByFrequency.day);
    _loadAverages();
  }

  // Load current year's report - FIXED with proper state reset
  void _loadCurrentYearReport() {
    final now = DateTime.now();
    setState(() {
      _selectedYear = now.year; // Reset to current year
      _currentTabIndex = 1; // Set to yearly tab
      _report = null; // Clear previous report data
    });
    
    final yearStart = DateTime(now.year, 1, 1);
    final yearEnd = DateTime(now.year, 12, 31, 23, 59, 59, 999);
    final actualEnd = now.isBefore(yearEnd) ? now : yearEnd;
    _refetchWithRange(yearStart, actualEnd, GroupByFrequency.month);
    _loadAverages();
  }

  Future<void> _refetchWithRange(DateTime start, DateTime end, GroupByFrequency groupBy) async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      _userId = user.uid;

      // Cap end to today
      final now = DateTime.now();
      if (end.isAfter(now)) {
        end = now;
      }

      print('Loading report with frequency: $groupBy, start: $start, end: $end'); // Debug log

      final result = await _reportService.generateReport(
        userId: _userId!,
        startDate: start,
        endDate: end,
        groupByFrequency: groupBy,
        animalTypes: const [AnimalType.buffalo, AnimalType.cow],
        generateAnimalBreakdown: true,
      );

      print('Report loaded with ${result.dataBreakdown?.length ?? 0} entries'); // Debug log

      if (!mounted) return;
      setState(() {
        _report = result;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading report: $e'); // Debug log
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage = 'Failed to load data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  String _formatCurrency(double? value) {
    if (value == null) return '0/-';
    return '${value.toStringAsFixed(2)}/-';
  }

  // Setup real-time listeners for average updates
  void _setupRealtimeListeners() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    _userId = user.uid;

    final userRef = FirebaseFirestore.instance.collection('users').doc(_userId);
    
    _incomeSub?.cancel();
    _expenseSub?.cancel();
    
    _incomeSub = userRef.collection('income').snapshots().listen((_) {
      _loadAverages();
    });
    
    _expenseSub = userRef.collection('expenses').snapshots().listen((_) {
      _loadAverages();
    });
  }

  // Load averages for current period
  Future<void> _loadAverages() async {
    if (_userId == null) return;

    final now = DateTime.now();
    GroupByFrequency frequency;
    DateTime startDate, endDate;

    if (_currentTabIndex == 0) {
      // Monthly tab - use day frequency
      frequency = GroupByFrequency.day;
      final month = _selectedMonthIndex + 1;
      startDate = DateTime(now.year, month, 1);
      endDate = DateTime(now.year, month + 1, 0, 23, 59, 59, 999);
      if (now.isBefore(endDate) && now.month == month) endDate = now;
    } else {
      // Yearly tab - use month frequency
      frequency = GroupByFrequency.month;
      startDate = DateTime(_selectedYear, 1, 1);
      endDate = DateTime(_selectedYear, 12, 31, 23, 59, 59, 999);
      if (_selectedYear == now.year && now.isBefore(endDate)) endDate = now;
    }

    try {
      final averages = await _reportService.calculateAverages(
        userId: _userId!,
        startDate: startDate,
        endDate: endDate,
        groupByFrequency: frequency,
        animalTypes: const [AnimalType.buffalo, AnimalType.cow],
      );

      if (!mounted) return;
      setState(() {
        _averageData = averages;
      });
    } catch (e) {
      print('Error loading averages: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _incomeSub?.cancel();
    _expenseSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return const SizedBox.shrink();
    
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[200],
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_hasError) {
      return Scaffold(
        backgroundColor: Colors.grey[200],
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 36),
                const SizedBox(height: 8),
                Text(_errorMessage ?? 'Failed to load reports', textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(onPressed: () => _loadCurrentMonthReport(), child: const Text('Retry')),
              ],
            ),
          ),
        ),
      );
    }
    
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
                      _buildTabButton(l10n.monthly, 0),
                      _buildTabButton(l10n.yearly, 1),
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
                      _buildReportContent(0, l10n), // Pass tab index
                      _buildReportContent(1, l10n), // Pass tab index
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
    final isSelected = _currentTabIndex == tabIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentTabIndex = tabIndex;
            _tabController.index = tabIndex;
          });
          
          // FIXED: Always reset to current month/year when switching tabs with proper frequency
          if (tabIndex == 0) {
            // Monthly tab
            _loadCurrentMonthReport();
          } else {
            // Yearly tab
            _loadCurrentYearReport();
          }
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

  // FIXED: Completely rewritten to use tab index instead of period label
  Widget _buildReportContent(int tabIndex, AppLocalizations l10n) {
    final List<String> monthOptions = Localizations.localeOf(context).languageCode == 'te'
        ? [
            l10n.january,
            l10n.february,
            l10n.march,
            l10n.april,
            l10n.may,
            l10n.june,
            l10n.july,
            l10n.august,
            l10n.september,
            l10n.october,
            l10n.november,
            l10n.december,
          ].sublist(0, DateTime.now().month)
        : ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
            .sublist(0, DateTime.now().month);
    final List<String> yearOptions = ['2022', '2023', '2024', '2025'];
    
    // FIXED: Use tab index to determine what to show
    final isMonthlyTab = tabIndex == 0;
    final frequency = isMonthlyTab ? GroupByFrequency.day : GroupByFrequency.month;
    
    // FIXED: Correct dropdown values based on tab
    String selectedPeriod;
    if (isMonthlyTab) {
      // Monthly tab - show month selector
      selectedPeriod = monthOptions[_selectedMonthIndex.clamp(0, 11)];
    } else {
      // Yearly tab - show year selector
      selectedPeriod = _selectedYear.toString();
    }

    print('Building content for tab: $tabIndex, isMonthly: $isMonthlyTab, selectedPeriod: $selectedPeriod'); // Debug

    return SingleChildScrollView(
      physics: _isTableZooming ? const NeverScrollableScrollPhysics() : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selectors
            Row(
              children: [
                SizedBox(
                  width: 180, // original pill width when both were present
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
                        // FIXED: Show correct options based on tab
                        items: (isMonthlyTab ? monthOptions : yearOptions)
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
                          if (value == null) return;
                          if (isMonthlyTab) {
                            // Monthly tab - month selection
                            final idx = monthOptions.indexOf(value);
                            if (idx >= 0) {
                              setState(() {
                                _selectedMonthIndex = idx;
                              });
                              final now = DateTime.now();
                              final month = idx + 1;
                              final start = DateTime(now.year, month, 1);
                              final endOfMonth = DateTime(now.year, month + 1, 0, 23, 59, 59, 999);
                              final end = now.isBefore(endOfMonth) && now.month == month ? now : endOfMonth;
                              _refetchWithRange(start, end, GroupByFrequency.day);
                              _loadAverages();
                            }
                          } else {
                            // Yearly tab - year selection
                            final year = int.tryParse(value);
                            if (year != null) {
                              setState(() {
                                _selectedYear = year;
                              });
                              final now = DateTime.now();
                              final start = DateTime(year, 1, 1);
                              final endOfYear = DateTime(year, 12, 31, 23, 59, 59, 999);
                              final end = (year == now.year && now.isBefore(endOfYear)) ? now : endOfYear;
                              _refetchWithRange(start, end, GroupByFrequency.month);
                              _loadAverages();
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Expanded(
                //   child: Container(
                //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                //     decoration: BoxDecoration(
                //       color: Colors.white,
                //       borderRadius: BorderRadius.circular(12),
                //       border: Border.all(color: Colors.black, width: 1),
                //     ),
                //     child: Text(
                //       '${l10n.date}: ${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}',
                //       style: const TextStyle(
                //         color: Colors.black,
                //         fontWeight: FontWeight.w600,
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
            const SizedBox(height: 18),
        
            // Table
            NotificationListener<ScaleStartNotification>(
              onNotification: (notification) {
                setState(() {
                  _isTableZooming = true;
                });
                return false;
              },
              child: NotificationListener<ScaleEndNotification>(
                onNotification: (notification) {
                  setState(() {
                    _isTableZooming = false;
                  });
                  return false;
                },
                child: ZoomableWidget(
                  minScale: 1.0,
                  maxScale: 3.0,
                  child: _buildReportTable(frequency, l10n), // Pass frequency
                ),
              ),
            ),
            const SizedBox(height: 18),
        
            // Chart Section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black, width: 1),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Custom Legend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem(const Color.fromARGB(255, 60, 132, 246), '${l10n.cow} ${l10n.milkL}'),
                      const SizedBox(width: 24),
                      _buildLegendItem(const Color.fromARGB(255, 248, 43, 43), '${l10n.buffalo} ${l10n.milkL}'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Line Chart
                  NotificationListener<ScaleStartNotification>(
                    onNotification: (notification) {
                      setState(() {
                        _isTableZooming = true;
                      });
                      return false;
                    },
                    child: NotificationListener<ScaleEndNotification>(
                      onNotification: (notification) {
                        setState(() {
                          _isTableZooming = false;
                        });
                        return false;
                      },
                      child: SizedBox(
                        height: 200,
                        child: ZoomableWidget(
                          minScale: 1.0,
                          maxScale: 4.0,
                          child: _buildMilkProductionChart(_report, frequency, l10n),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Chart Statistics - Dynamic Averages
                  _buildDynamicAverages(frequency, l10n),
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
                    frequency == GroupByFrequency.day
                        ? l10n.monthlyIncome
                        : l10n.yearlyIncome,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildIncomeRow(
                    l10n.expenseHeader,
                    _formatCurrency((_report?.summary.expense as num?)?.toDouble()),
                  ),
                  const SizedBox(height: 8),
                  _buildIncomeRow(
                    l10n.incomeHeader,
                    _formatCurrency(_report?.summary.yield.income),
                  ),
                  const SizedBox(height: 8),
                  _buildIncomeRow(
                    l10n.profitHeader,
                    _formatCurrency(_report?.summary.profit),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }

  // Helper widget for the legend
  Widget _buildLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Line Chart Widget
  Widget _buildMilkProductionChart(Report? report, GroupByFrequency frequency, AppLocalizations l10n) {
    if (report == null || report.dataBreakdown == null || report.dataBreakdown!.isEmpty) {
      return const Center(
        child: Text(
          'No data available for chart',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      );
    }

    // Extract and sort data points
    final sortedEntries = report.dataBreakdown!.entries.toList()
      ..sort((a, b) => _compareKeys(a.key, b.key, frequency));

    final cowSpots = <FlSpot>[];
    final buffaloSpots = <FlSpot>[];
    final bottomLabels = <int, String>{};

    for (var i = 0; i < sortedEntries.length; i++) {
      final entry = sortedEntries[i];
      final metrics = entry.value;

      final cowData = metrics.animalBreakdown[AnimalType.cow];
      final buffaloData = metrics.animalBreakdown[AnimalType.buffalo];

      // Add data points, defaulting to 0 if null
      cowSpots.add(FlSpot(i.toDouble(), cowData?.milkQuantity ?? 0.0));
      buffaloSpots.add(FlSpot(i.toDouble(), buffaloData?.milkQuantity ?? 0.0));

      // Bottom axis label per frequency - FIXED to remove leading zeros
      String key = entry.key;
      switch (frequency) {
        case GroupByFrequency.day:
          // Convert "01", "02" to "1", "2" 
          final dayNumber = int.tryParse(key) ?? 0;
          bottomLabels[i] = dayNumber.toString();
          break;
        case GroupByFrequency.week:
          // Normalize Week labels (W1, Week1 -> W1)
          final cleaned = key.toUpperCase().replaceAll('WEEK', '').replaceAll('W', '').trim();
          final weekNum = int.tryParse(cleaned) ?? 0;
          bottomLabels[i] = 'W$weekNum';
          break;
        case GroupByFrequency.month:
          final map = {
            'JANUARY': 'Jan','JAN': 'Jan',
            'FEBRUARY': 'Feb','FEB': 'Feb',
            'MARCH': 'Mar','MAR': 'Mar',
            'APRIL': 'Apr','APR': 'Apr',
            'MAY': 'May',
            'JUNE': 'Jun','JUN': 'Jun',
            'JULY': 'Jul','JUL': 'Jul',
            'AUGUST': 'Aug','AUG': 'Aug',
            'SEPTEMBER': 'Sep','SEP': 'Sep',
            'OCTOBER': 'Oct','OCT': 'Oct',
            'NOVEMBER': 'Nov','NOV': 'Nov',
            'DECEMBER': 'Dec','DEC': 'Dec',
          };
          bottomLabels[i] = map[key.trim().toUpperCase()] ?? key;
          break;
        case GroupByFrequency.year:
          bottomLabels[i] = key;
          break;
        case GroupByFrequency.quarter: // Added missing case
          bottomLabels[i] = key;
          break;
      }
    }

    // Determine Y-axis ticks
    final maxCow = cowSpots.isEmpty ? 0.0 : cowSpots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    final maxBuffalo = buffaloSpots.isEmpty ? 0.0 : buffaloSpots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    final maxY = [maxCow, maxBuffalo, 1.0].reduce((a, b) => a > b ? a : b);
    final step = (maxY / 4).clamp(1.0, double.infinity);

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          show: true,
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              interval: step,
              getTitlesWidget: (value, meta) {
                if (value < 0) return const SizedBox.shrink();
                return Text('${value.toStringAsFixed(0)}L', style: const TextStyle(fontSize: 10, color: Colors.black));
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                final label = bottomLabels[idx];
                if (label == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(label, style: const TextStyle(fontSize: 10, color: Colors.black)),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        backgroundColor: Colors.white,
        lineBarsData: [
          // Cow Milk Line (Blue)
          LineChartBarData(
            spots: cowSpots,
            isCurved: true,
            color: const Color.fromARGB(255, 60, 132, 246),
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: false),
          ),
          // Buffalo Milk Line (Red)
          LineChartBarData(
            spots: buffaloSpots,
            isCurved: true,
            color: const Color.fromARGB(255, 248, 43, 43),
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: false),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.black.withOpacity(0.8),
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final flSpot = barSpot;
                String animalType = flSpot.barIndex == 0 ? l10n.cow : l10n.buffalo;
                return LineTooltipItem(
                  '$animalType: ${flSpot.y.toStringAsFixed(1)}L',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
          handleBuiltInTouches: true,
        ),
        minY: 0,
      ),
    );
  }

  // Helper to compare keys for sorting
  int _compareKeys(String a, String b, GroupByFrequency frequency) {
    switch (frequency) {
      case GroupByFrequency.day:
        int day(String s) => int.tryParse(s.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        return day(a).compareTo(day(b));
      case GroupByFrequency.week:
        int parseWeek(String s) {
          final cleaned = s.toUpperCase().replaceAll('WEEK', '').replaceAll('W', '').trim();
          return int.tryParse(cleaned) ?? 0;
        }
        final weekA = parseWeek(a);
        final weekB = parseWeek(b);
        return weekA.compareTo(weekB);
      
      case GroupByFrequency.month:
        int monthIndex(String s) {
          final map = {
            'JANUARY': 0, 'JAN': 0,
            'FEBRUARY': 1, 'FEB': 1,
            'MARCH': 2, 'MAR': 2,
            'APRIL': 3, 'APR': 3,
            'MAY': 4,
            'JUNE': 5, 'JUN': 5,
            'JULY': 6, 'JUL': 6,
            'AUGUST': 7, 'AUG': 7,
            'SEPTEMBER': 8, 'SEP': 8,
            'OCTOBER': 9, 'OCT': 9,
            'NOVEMBER': 10, 'NOV': 10,
            'DECEMBER': 11, 'DEC': 11,
          };
          return map[s.trim().toUpperCase()] ?? -1;
        }
        final monthA = monthIndex(a);
        final monthB = monthIndex(b);
        return monthA.compareTo(monthB);
      
      case GroupByFrequency.year:
        final yearA = int.tryParse(a) ?? 0;
        final yearB = int.tryParse(b) ?? 0;
        return yearA.compareTo(yearB);
      
      case GroupByFrequency.quarter:
        return a.compareTo(b);
    }
  }

  // FIXED: Simplified table building using frequency parameter
  Widget _buildReportTable(GroupByFrequency frequency, AppLocalizations l10n) {
    final isDay = frequency == GroupByFrequency.day;
    final String firstColumnHeader = isDay ? l10n.day : l10n.month;

    print('Building table with frequency: $frequency, isDay: $isDay'); // Debug log

    // Build data from backend report if available
    final breakdown = _report?.dataBreakdown;
    final List<Map<String, dynamic>> data;
    
    if (breakdown != null && breakdown.isNotEmpty) {
      print('Report breakdown has ${breakdown.length} entries'); // Debug log
      final entries = breakdown.entries.toList()
        ..sort((a, b) => _compareKeys(a.key, b.key, frequency));
      
      data = entries.map((entry) {
        final key = entry.key;
        final ReportMetrics metrics = entry.value;
        final cow = metrics.animalBreakdown[AnimalType.cow] ?? const YieldMetrics();
        final buffalo = metrics.animalBreakdown[AnimalType.buffalo] ?? const YieldMetrics();
        
        // For days, remove leading zeros from display
        String displayKey = key;
        if (isDay) {
          final dayNumber = int.tryParse(key) ?? 0;
          displayKey = dayNumber.toString();
        }
        
        print('Table entry: $displayKey - Cow: ${cow.milkQuantity}, Buffalo: ${buffalo.milkQuantity}'); // Debug log
        
        return {
          'period': displayKey,
          'values': [
            cow.milkQuantity.toStringAsFixed(0),
            cow.avgSnf.toStringAsFixed(0),
            cow.avgFat.toStringAsFixed(0),
            buffalo.milkQuantity.toStringAsFixed(0),
            buffalo.avgSnf.toStringAsFixed(0),
            buffalo.avgFat.toStringAsFixed(0),
          ],
        };
      }).toList();
    } else {
      print('No report breakdown data available'); // Debug log
      // Fallback dummy if no data yet
      data = [
        {'period': isDay ? '1' : 'Jan', 'values': ['0','0','0','0','0','0']},
      ];
    }
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTableHeader(firstColumnHeader, l10n),
          ..._buildDataRows(data),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String firstColumnHeader, AppLocalizations l10n) {
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
              _buildHeaderCell(l10n.cow, flex: 30),
              _buildHeaderCell(l10n.buffalo, flex: 30, hasRightBorder: false),
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
              _buildSubHeaderCell(l10n.milkLHeader, flex: 10, hasLeftBorder: true),
              _buildSubHeaderCell(l10n.snfHeader, flex: 10),
              _buildSubHeaderCell(l10n.fatHeader, flex: 10),
              _buildSubHeaderCell(l10n.milkLHeader, flex: 10, hasLeftBorder: true),
              _buildSubHeaderCell(l10n.snfHeader, flex: 10),
              _buildSubHeaderCell(l10n.fatHeader, flex: 10, hasRightBorder: false),
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
    final isMilk = text.contains('Milk');
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

  // Build dynamic averages based on actual data
  Widget _buildDynamicAverages(GroupByFrequency frequency, AppLocalizations l10n) {
    if (_averageData == null) {
      return const Text(
        'Loading averages...',
        style: TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      );
    }

    final milkAvg = _averageData!['milkAverage'] as double? ?? 0.0;
    final fatAvg = _averageData!['fatAverage'] as double? ?? 0.0;
    final snfAvg = _averageData!['snfAverage'] as double? ?? 0.0;
    final dataPoints = _averageData!['dataPoints'] as int? ?? 0;

    if (dataPoints == 0) {
      return const Text(
        'No data available for averages',
        style: TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      );
    }

    // Format averages based on frequency
    String milkText, fatText, snfText;
    if (frequency == GroupByFrequency.day) {
      // Monthly view - show daily averages
      milkText = '${l10n.milk} Daily Average: ${milkAvg.toStringAsFixed(1)}L';
      fatText = '${l10n.fat} Daily Average: ${fatAvg.toStringAsFixed(1)}%';
      snfText = '${l10n.snf} Daily Average: ${snfAvg.toStringAsFixed(1)}';
    } else {
      // Yearly view - show monthly averages
      milkText = '${l10n.milk} Monthly Average: ${milkAvg.toStringAsFixed(1)}L';
      fatText = '${l10n.fat} Monthly Average: ${fatAvg.toStringAsFixed(1)}%';
      snfText = '${l10n.snf} Monthly Average: ${snfAvg.toStringAsFixed(1)}';
    }

    return Text(
      '$milkText\n$fatText\n$snfText',
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
      textAlign: TextAlign.center,
    );
  }
}
