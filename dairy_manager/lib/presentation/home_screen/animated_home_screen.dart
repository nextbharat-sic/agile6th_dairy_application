import 'dart:ui';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../backend/repositories/expense_repository.dart';
import '../../backend/repositories/income_repository.dart';
import '../../backend/services/report_service.dart';
import '../../constants/constants.dart';
import '../../models/report_models.dart';
import '../../providers/auth_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/date_utils.dart';


class AnimatedHomeScreen extends StatefulWidget {
  const AnimatedHomeScreen({super.key});

  @override
  State<AnimatedHomeScreen> createState() => _AnimatedHomeScreenState();
}

class _AnimatedHomeScreenState extends State<AnimatedHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _milkDripController;
  late AnimationController _buttonsController;
  late Animation<double> _milkDripAnimation;
  late Animation<double> _buttonsAnimation;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();


    _milkDripController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _buttonsController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _milkDripAnimation = Tween<double>(
      begin: 0.0,
      end: -1.5, // Move further up so it becomes fully invisible
    ).animate(CurvedAnimation(
      parent: _milkDripController,
      curve: Curves.easeInOutExpo,
    ));

    _buttonsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buttonsController,
      curve: Curves.easeInOutExpo,
    ));
  }

  @override
  void dispose() {
    _milkDripController.dispose();
    _buttonsController.dispose();
    super.dispose();
  }

  void _handleSwipeUp() {
    HapticFeedback.lightImpact();
    setState(() {
      _isExpanded = true;
    });
    _milkDripController.forward();
    _buttonsController.forward();
  }

  void _handleSwipeDown() {
    HapticFeedback.lightImpact();
    setState(() {
      _isExpanded = false;
    });
    _milkDripController.reverse();
    _buttonsController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userName = authProvider.userName ?? 'User';
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Removed top light background to avoid white rectangle during swipe
          // Main content with DraggableScrollableSheet
          DraggableScrollableSheet(
            initialChildSize: 0.75,
            minChildSize: 0.75,
            maxChildSize: 1.0,
            builder: (context, scrollController) {
              return NotificationListener<DraggableScrollableNotification>(
                onNotification: (notification) {
                  if (notification.extent > 0.85 && !_isExpanded) {
                    _handleSwipeUp();
                  } else if (notification.extent < 0.8 && _isExpanded) {
                    _handleSwipeDown();
                  }
                  return false;
                },
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      children: [
                        // Animated spacing that moves everything upwards
                        AnimatedBuilder(
                          animation: _buttonsAnimation,
                          builder: (context, child) {
                            return SizedBox(
                              height: 175 - (_buttonsAnimation.value * 40),
                            );
                          },
                        ),
                        // RakuDiary Title and Settings icon on same line
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildRakuDiaryTitle(),
                              GestureDetector(
                                onTap: () =>
                                    Navigator.pushNamed(context, '/settings'),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.settings,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 35),
                        // Infinite Glass Morphism Carousel
                        InfiniteGlassCarousel(l10n: l10n),
                        const SizedBox(height: 40),
                        // Navigation Buttons (animated)
                        AnimatedBuilder(
                          animation: _buttonsAnimation,
                          child: _buildNavigationButtons(l10n),
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(
                                  0, (1 - _buttonsAnimation.value) * 100),
                              child: Opacity(
                                opacity: _buttonsAnimation.value,
                                child: child,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          // Animated Milk Drip Overlay at the top
          AnimatedBuilder(
            animation: _milkDripAnimation,
            builder: (context, child) {
              return Positioned(
                // Raise initial position so drips are visible in collapsed state
                top: 32 + (_milkDripAnimation.value * MediaQuery.of(context).size.height * 0.45),
                left: 0,
                right: 0,
                child: SizedBox(
                  // Slightly reduce to frame the drip shape better
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: Image.asset(
                    'assets/images/milkdrip-.png',
                    width: double.infinity,
                    height: double.infinity,
                    alignment: Alignment.topCenter,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRakuDiaryTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'RakuNo',
          style: TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.8,
            fontFamily: 'Montserrat',
          ),
        ),
        Stack(
          children: [
            Text(
              'Te',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.8,
                fontFamily: 'Montserrat',
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 3.5
                  ..color = Colors.white,
              ),
            ),
            Text(
              'Te',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 40,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.8,
                fontFamily: 'Montserrat',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNavigationButtons(AppLocalizations l10n) {
    return Column(
      children: [
        // Large Milk Entry Button with icon in center
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
          child: ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/milk-entry'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 20),
              backgroundColor: const Color(0xFFD8D8D8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 8,
              shadowColor: Colors.black26,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.milk,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                    color: Colors.black,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Image.asset(
                      'assets/images/milk_entry.png',
                      fit: BoxFit.contain,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.entry,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                    color: Colors.black,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
          ),
        ),

        // Row of two smaller buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            children: [
              // Reports Button
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/reports'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFFD8D8D8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 8,
                    shadowColor: Colors.black26,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Image.asset(
                            'assets/images/reports.png',
                            fit: BoxFit.contain,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.reports,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Colors.black,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Expenses Button
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/expenses'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFFD8D8D8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 8,
                    shadowColor: Colors.black26,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            'assets/images/expenses.png',
                            fit: BoxFit.contain,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.expenses,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Colors.black,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class InfiniteGlassCarousel extends StatefulWidget {
  final AppLocalizations l10n;
  
  const InfiniteGlassCarousel({super.key, required this.l10n});

  @override
  State<InfiniteGlassCarousel> createState() => _InfiniteGlassCarouselState();
}

class _InfiniteGlassCarouselState extends State<InfiniteGlassCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;
  late final ReportService _reportService;
  String? _userId;
  
  List<Map<String, String>> _monthsData = [];
  // final List<Map<String, String>> _monthsData = const [
  //   {'name': 'JANUARY', 'expense': '1234', 'revenue': '2468', 'profit': '1234'},
  //   {'name': 'FEBRUARY', 'expense': '1500', 'revenue': '2800', 'profit': '1300'},
  //   {'name': 'MARCH', 'expense': '1100', 'revenue': '2200', 'profit': '1100'},
  //   {'name': 'APRIL', 'expense': '1800', 'revenue': '3200', 'profit': '1400'},
  //   {'name': 'MAY', 'expense': '1600', 'revenue': '2900', 'profit': '1300'},
  //   {'name': 'JUNE', 'expense': '1400', 'revenue': '2600', 'profit': '1200'},
  //   {'name': 'JULY', 'expense': '1900', 'revenue': '3400', 'profit': '1500'},
  //   {'name': 'AUGUST', 'expense': '1700', 'revenue': '3100', 'profit': '1400'},
  //   {'name': 'SEPTEMBER', 'expense': '1300', 'revenue': '2400', 'profit': '1100'},
  //   {'name': 'OCTOBER', 'expense': '2000', 'revenue': '3600', 'profit': '1600'},
  //   {'name': 'NOVEMBER', 'expense': '1800', 'revenue': '3200', 'profit': '1400'},
  //   {'name': 'DECEMBER', 'expense': '2200', 'revenue': '4000', 'profit': '1800'},
  // ];

  @override
  void initState() {
    super.initState();

    final firestore = FirebaseFirestore.instance;
    final incomeRepo = IncomeRepository(firestore);
    final expenseRepo = ExpenseRepository(firestore);
    _reportService = ReportService(
      incomeRepository: incomeRepo,
      expenseRepository: expenseRepo,
    );

    // Initialize with default data to prevent division by zero
    _initializeDefaultData();
    
    final currentMonth = DateTime.now().month - 1; // 0..11
    final initialIndex = _resolveMonthIndexInData(currentMonth);
    final initialPage = (_monthsData.length * 1000) + initialIndex;
    _pageController = PageController(
      viewportFraction: 0.6,
      initialPage: initialPage,
    );
    _currentPage = currentMonth;

    _loadReport();
    _setupRealtimeListeners();
    // Ensure current month is centered on first paint
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureCurrentMonthCentered();
    });
  }

  // Initialize with 12 months of empty data to prevent errors
  void _initializeDefaultData() {
    final months = ['JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE',
                   'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER'];
    
    _monthsData = months.map((month) => {
      'name': month,
      'expense': '0',
      'profit': '0.00',
      'revenue': '0.00',
    }).toList();
  }

  Future<void> _loadReport() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {

      return;
    }
    _userId = user.uid;

      final result = await _reportService.generateReport(
        userId: _userId!,
        startDate: DateUtils.getFirstDayOfYear(),
        endDate: DateUtils.getToday(),
        groupByFrequency: GroupByFrequency.month,
        animalTypes: [AnimalType.buffalo, AnimalType.cow],
        generateAnimalBreakdown: false,
      );

    if (!mounted) return;
    setState(() {
      _monthsData = getMonthDataList(result);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Helper to check if a month is the current month
  bool _isCurrentMonth(int monthIndex) {
    final currentMonth = DateTime.now().month - 1;
    return monthIndex == currentMonth;
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator
    if (_isLoading) {
      return SizedBox(
        height: 280,
        child: Center(
          child: CircularProgressIndicator(
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      );
    }

    // Show error message
    if (_hasError) {
      return SizedBox(
        height: 280,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.white.withOpacity(0.7),
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? 'Something went wrong',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _hasError = false;
                  });
                  _loadReport();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Ensure we have data before building PageView
    if (_monthsData.isEmpty) {
      return SizedBox(
        height: 280,
        child: Center(
          child: Text(
            'No data available',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 280,
      child: PageView.builder(
        controller: _pageController,
        // Infinite scrolling by omitting itemCount
        onPageChanged: (index) {
          setState(() {
            _currentPage = index % _monthsData.length;
          });
        },
        itemBuilder: (context, index) {
          final actualIndex = index % _monthsData.length;
          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double value = 1.0;
              if (_pageController.position.haveDimensions) {
                value = ((_pageController.page ?? _pageController.initialPage) - index).toDouble();
                value = (1 - (value.abs() * 0.3)).clamp(0.6, 1.0);
              }

              return Transform.scale(
                scale: value,
                child: Opacity(
                  opacity: value < 0.8 ? 0.3 : 1.0,
                  child: child,
                ),
              );
            },
            child: _buildGlassCard(_monthsData[actualIndex], actualIndex, widget.l10n),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _incomeSub?.cancel();
    _expenseSub?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  String _getTranslatedMonthName(String monthName, AppLocalizations l10n) {
    final key = monthName.trim().toUpperCase();
    switch (key) {
      case 'JAN':
      case 'JANUARY': return l10n.january;
      case 'FEB':
      case 'FEBRUARY': return l10n.february;
      case 'MAR':
      case 'MARCH': return l10n.march;
      case 'APR':
      case 'APRIL': return l10n.april;
      case 'MAY': return l10n.may;
      case 'JUN':
      case 'JUNE': return l10n.june;
      case 'JUL':
      case 'JULY': return l10n.july;
      case 'AUG':
      case 'AUGUST': return l10n.august;
      case 'SEP':
      case 'SEPTEMBER': return l10n.september;
      case 'OCT':
      case 'OCTOBER': return l10n.october;
      case 'NOV':
      case 'NOVEMBER': return l10n.november;
      case 'DEC':
      case 'DECEMBER': return l10n.december;
      default: return monthName;
    }
  }

  Widget _buildGlassCard(Map<String, String> monthData, int monthIndex, AppLocalizations l10n) {
    final isCurrentMonth = _isCurrentMonth(monthIndex);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.2),
                  Colors.white.withValues(alpha: 0.05),
                  Colors.black.withValues(alpha: 0.3),
                ],
                stops: const [0.0, 0.3, 1.0],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isCurrentMonth
                    ? Colors.white.withOpacity(0.6)
                    : Colors.white.withValues(alpha: 0.2),
                width: isCurrentMonth ? 2.0 : 1.5,
              ),
              boxShadow: [
                // Exterior neon glow for current month only
                if (isCurrentMonth) ...[
                  // Minimal inner glow layer
                  BoxShadow(
                    color: Colors.white.withOpacity(0.25),
                    blurRadius: 4,
                    spreadRadius: 1,
                    offset: const Offset(0, 0),
                  ),
                  // Middle glow layer (unchanged)
                  BoxShadow(
                    color: Colors.white.withOpacity(0.5),
                    blurRadius: 35,
                    spreadRadius: 4,
                    offset: const Offset(0, 0),
                  ),
                  // Enhanced outer glow layer
                  BoxShadow(
                    color: Colors.white.withOpacity(0.45),
                    blurRadius: 80,
                    spreadRadius: 12,
                    offset: const Offset(0, 0),
                  ),
                ],
                // Default shadows for all cards
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(-5, -5),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _getTranslatedMonthName(monthData['name']!, l10n),
                  style: TextStyle(
                    color: isCurrentMonth
                        ? Colors.white
                        : Colors.white.withOpacity(0.9),
                    fontSize: isCurrentMonth ? 28 : 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 8),
                _buildDataRow(l10n.expense, monthData['expense']!, isCurrentMonth: isCurrentMonth),
                const SizedBox(height: 4),
                _buildDataRow(l10n.revenue, monthData['revenue']!, isCurrentMonth: isCurrentMonth),
                const SizedBox(height: 4),
                _buildDataRow(l10n.profit, monthData['profit']!, isProfit: true, isCurrentMonth: isCurrentMonth),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value,
      {bool isProfit = false, bool isCurrentMonth = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment:
          isProfit ? CrossAxisAlignment.end : CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isCurrentMonth
                ? Colors.white
                : Colors.white.withValues(alpha: 0.9),
            fontSize: isProfit ? 27 : 22,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            fontFamily: 'Montserrat',
          ),
        ),
        Text(
          '$value/-',
          style: TextStyle(
            color: isCurrentMonth
                ? Colors.white
                : Colors.white.withValues(alpha: 0.95),
            fontSize: isProfit ? 24 : 18,
            fontWeight: isProfit ? FontWeight.bold : FontWeight.w800,
            fontFamily: 'Montserrat',
          ),
        ),
      ],
    );
  }
}
