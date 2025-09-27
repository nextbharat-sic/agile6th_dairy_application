import 'dart:ui';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter/services.dart';
import '../../backend/repositories/expense_repository.dart';
import '../../backend/repositories/income_repository.dart';
import '../../backend/services/report_service.dart';
import '../../constants/constants.dart';
import '../../models/report_models.dart';
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
  
  // Add DraggableScrollableController
  late DraggableScrollableController _draggableController;
  Timer? _autoSwipeTimer;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();

    // Initialize the draggable controller
    _draggableController = DraggableScrollableController();

    // SYNCHRONIZED: Both controllers use same duration for sync
    _milkDripController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _buttonsController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _milkDripAnimation = Tween<double>(
      begin: 0.0,
      end: -1.5,
    ).animate(CurvedAnimation(
      parent: _milkDripController,
      curve: Curves.easeInOutCubic,
    ));

    _buttonsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buttonsController,
      curve: Curves.easeInOutCubic,
    ));

    // Start automatic swipe timer for 2 seconds
    _startAutoSwipeTimer();
  }

  void _startAutoSwipeTimer() {
    _autoSwipeTimer = Timer(const Duration(seconds: 2), () {
      if (mounted && !_isExpanded) {
        _expandToFullScreen();
      }
    });
  }

  void _expandToFullScreen() async {
    HapticFeedback.lightImpact();
    setState(() {
      _isExpanded = true;
    });
    
    // SYNCHRONIZED: Start all animations together
    _milkDripController.forward();
    _buttonsController.forward();
    
    // Single smooth animation to target position
    await _draggableController.animateTo(
      1.0,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _autoSwipeTimer?.cancel();
    _milkDripController.dispose();
    _buttonsController.dispose();
    _draggableController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main content with DraggableScrollableSheet - DISABLED MANUAL INTERACTION
          DraggableScrollableSheet(
            controller: _draggableController,
            initialChildSize: 0.75,
            minChildSize: 0.75,
            maxChildSize: 1.0,
            snap: false, // Disabled snapping
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  // DISABLED: Manual scrolling completely disabled
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      // ADJUSTED: Moderate height reduction to match your image
                      AnimatedBuilder(
                        animation: _buttonsAnimation,
                        builder: (context, child) {
                          return SizedBox(
                            height: 175 - (_buttonsAnimation.value * 90), // REDUCED: 80px instead of 120px
                          );
                        },
                      ),
                      
                      // ADJUSTED: Moderate content push to position title correctly
                      AnimatedBuilder(
                        animation: _buttonsAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, -(_buttonsAnimation.value * 35)), // REDUCED: 20px instead of 80px
                            child: child,
                          );
                        },
                        child: Column(
                          children: [
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
                            // Navigation Buttons
                            AnimatedBuilder(
                              animation: _buttonsAnimation,
                              child: _buildNavigationButtons(l10n),
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(
                                      0, (1 - _buttonsAnimation.value) * 120), // Keep button animation as is
                                  child: Opacity(
                                    opacity: _buttonsAnimation.value,
                                    child: child,
                                  ),
                                );
                              },
                            ),
                            
                            // ADJUSTED: Moderate invisible spacer
                            AnimatedBuilder(
                              animation: _buttonsAnimation,
                              builder: (context, child) {
                                return SizedBox(
                                  height: 20 + (_buttonsAnimation.value * 40), // REDUCED: 40px instead of 150px
                                );
                              },
                            ),
                            
                            // ADJUSTED: Moderate bottom padding
                            SizedBox(height: 60 + MediaQuery.of(context).padding.bottom), // REDUCED: 60px instead of 150px
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // Milk Drip Overlay with synchronized timing
          AnimatedBuilder(
            animation: _milkDripAnimation,
            builder: (context, child) {
              return Positioned(
                // ADJUSTED: Moderate positioning to match your image
                top: 32 + (_milkDripAnimation.value * MediaQuery.of(context).size.height * 0.35), // REDUCED: 0.35 instead of 0.6
                left: 0,
                right: 0,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4, // REDUCED: 0.4 instead of 0.6
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
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        // Logo on the left, animated with the title
        AnimatedBuilder(
          animation: _buttonsAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: 0.8 + (_buttonsAnimation.value * 0.2), // subtle scale in
              child: child,
            );
          },
          child: Baseline(
            baseline: 50,
            baselineType: TextBaseline.alphabetic,
            child: Image.asset(
              'assets/images/logo.png',
              height: 60,
              width: 60,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(width: 0),
        const Text(
          'Kisan',
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
              'Diary',
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
              'Diary',
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

// Modified InfiniteGlassCarousel with ENABLED infinite scrolling
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
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _incomeSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _expenseSub;
  
  // ADDED: Timer for infinite auto-scroll
  Timer? _carouselTimer;
  static const Duration _scrollDuration = Duration(seconds: 3);

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

    _initializeDefaultData();
    
    final currentMonth = DateTime.now().month - 1;
    final initialIndex = _resolveMonthIndexInData(currentMonth);
    final initialPage = (_monthsData.length * 1000) + initialIndex;
    _pageController = PageController(
      viewportFraction: 0.6,
      initialPage: initialPage,
    );
    _currentPage = currentMonth;

    _loadReport();
    _setupRealtimeListeners();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureCurrentMonthCentered();
      _startCarouselTimer(); // Start auto-scroll after initial setup
    });
  }

  // ADDED: Start carousel auto-scroll timer
  void _startCarouselTimer() {
    // Disabled auto-scroll: carousel is user-controlled only
    _carouselTimer?.cancel();
  }

  void _initializeDefaultData() {
    final now = DateTime.now();
    final currentMonthIndex = now.month - 1;
    final months = [
      'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE',
      'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER'
    ];
    _monthsData = months.take(currentMonthIndex + 1).map((month) => {
      'name': month,
      'expense': '0',
      'profit': '0.00',
      'revenue': '0.00',
    }).toList();
  }

  Future<void> _loadReport() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
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
      final now = DateTime.now();
      final currentMonthIndex = now.month - 1;
      final allMonths = getMonthDataList(result);
      _monthsData = allMonths.take(currentMonthIndex + 1).toList();
    });
    
    // Ensure current month is visible by default
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureCurrentMonthCentered();
    });
    
    // Restart timer after data update
    if (_monthsData.isNotEmpty) {
      _startCarouselTimer();
    }
  }

  @override
  void dispose() {
    _carouselTimer?.cancel(); // ADDED: Cancel carousel timer
    _incomeSub?.cancel();
    _expenseSub?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  bool _isCurrentMonth(int monthIndex) {
    final currentMonth = DateTime.now().month - 1;
    return monthIndex == currentMonth;
  }

  @override
  Widget build(BuildContext context) {
    if (_monthsData.isEmpty) {
      return SizedBox(
        height: 280,
        child: Center(
          child: Text(
            'No data available',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
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
        // ENABLED: Removed NeverScrollableScrollPhysics to enable infinite scrolling
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

  List<Map<String, String>> getMonthDataList(Report report) {
    final ordered = const [
      'JANUARY','FEBRUARY','MARCH','APRIL','MAY','JUNE',
      'JULY','AUGUST','SEPTEMBER','OCTOBER','NOVEMBER','DECEMBER'
    ];
    final Map<String, Map<String, String>> byName = {
      for (final m in ordered)
        m: {'name': m, 'expense': '0', 'profit': '0', 'revenue': '0'}
    };
    if (report.dataBreakdown != null) {
      report.dataBreakdown!.forEach((key, metrics) {
        final k = key.trim().toUpperCase();
        String normalize(String s) {
          switch (s) {
            case 'JAN': return 'JANUARY';
            case 'FEB': return 'FEBRUARY';
            case 'MAR': return 'MARCH';
            case 'APR': return 'APRIL';
            case 'MAY': return 'MAY';
            case 'JUN': return 'JUNE';
            case 'JUL': return 'JULY';
            case 'AUG': return 'AUGUST';
            case 'SEP': return 'SEPTEMBER';
            case 'OCT': return 'OCTOBER';
            case 'NOV': return 'NOVEMBER';
            case 'DEC': return 'DECEMBER';
            default: return s;
          }
        }
        final norm = normalize(k);
        if (byName.containsKey(norm)) {
          byName[norm] = {
            'name': norm,
            'expense': (metrics.expense as num).toInt().toString(),
            'profit': (metrics.profit as num).toInt().toString(),
            'revenue': (metrics.yield.income as num).toInt().toString(),
          };
        }
      });
    }
    return ordered.map((n) => byName[n]!).toList();
  }

  int _resolveMonthIndexInData(int desiredMonthIndex) {
    int nameToIndex(String name) {
      final k = name.trim().toUpperCase();
      switch (k) {
        case 'JAN':
        case 'JANUARY': return 0;
        case 'FEB':
        case 'FEBRUARY': return 1;
        case 'MAR':
        case 'MARCH': return 2;
        case 'APR':
        case 'APRIL': return 3;
        case 'MAY': return 4;
        case 'JUN':
        case 'JUNE': return 5;
        case 'JUL':
        case 'JULY': return 6;
        case 'AUG':
        case 'AUGUST': return 7;
        case 'SEP':
        case 'SEPTEMBER': return 8;
        case 'OCT':
        case 'OCTOBER': return 9;
        case 'NOV':
        case 'NOVEMBER': return 10;
        case 'DEC':
        case 'DECEMBER': return 11;
        default: return -1;
      }
    }
    final idx = _monthsData.indexWhere((m) => nameToIndex(m['name'] ?? '') == desiredMonthIndex);
    if (idx != -1) return idx;
    if (desiredMonthIndex >= 0 && desiredMonthIndex < _monthsData.length) return desiredMonthIndex;
    return 0;
  }

  void _ensureCurrentMonthCentered() {
    if (!_pageController.hasClients) return;
    final current = DateTime.now().month - 1;
    final idx = _resolveMonthIndexInData(current);
    final target = (_monthsData.length * 1000) + idx;
    _pageController.jumpToPage(target);
    _currentPage = idx;
  }

  void _setupRealtimeListeners() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    _userId = user.uid;
    final userRef = FirebaseFirestore.instance.collection('users').doc(_userId);
    _incomeSub?.cancel();
    _expenseSub?.cancel();
    _incomeSub = userRef.collection('income').snapshots().listen((_) => _loadReport());
    _expenseSub = userRef.collection('expenses').snapshots().listen((_) => _loadReport());
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
                    ? Colors.white.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.2),
                width: isCurrentMonth ? 2.0 : 1.5,
              ),
              boxShadow: [
                if (isCurrentMonth) ...[
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.25),
                    blurRadius: 4,
                    spreadRadius: 1,
                    offset: const Offset(0, 0),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.5),
                    blurRadius: 35,
                    spreadRadius: 4,
                    offset: const Offset(0, 0),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.45),
                    blurRadius: 80,
                    spreadRadius: 12,
                    offset: const Offset(0, 0),
                  ),
                ],
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
            child: Stack(
              children: [
                // Current year in top right corner
                
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      '${DateTime.now().year}',
                      style: TextStyle(
                        color: isCurrentMonth
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.8),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                ),

                // Main content column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getTranslatedMonthName(monthData['name']!, l10n),
                      style: TextStyle(
                        color: isCurrentMonth
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.9),
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
