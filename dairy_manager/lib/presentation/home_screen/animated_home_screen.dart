import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

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
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _buttonsController = AnimationController(
      duration: const Duration(milliseconds: 400), // Changed from 300 to 400 to match milk drip
      vsync: this,
    );

    _milkDripAnimation = Tween<double>(
      begin: 0.0,
      end: -1.0,
    ).animate(CurvedAnimation(
      parent: _milkDripController,
      curve: Curves.easeOutCubic,
    ));

    _buttonsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buttonsController,
      curve: Curves.easeOutCubic,
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
    // Animate both controllers forward with same timing
    _milkDripController.forward();
    _buttonsController.forward();
  }

  void _handleSwipeDown() {
    HapticFeedback.lightImpact();
    setState(() {
      _isExpanded = false;
    });
    // Animate both controllers reverse with same timing
    _milkDripController.reverse();
    _buttonsController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userName = authProvider.userName ?? 'User';
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Top color fill for milk drip area
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.15, // Reduced to only fill the top black area after milk drip shift
            child: Container(
              color: const Color(0xFFF8F8F8), // Exact match to milk drip PNG color
            ),
          ),
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
                        const SizedBox(height: 135), // Increased from 75 to 135 (60px additional)
                        // RakuDiary Title and Settings icon on same line
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // RakuDiary Title
                              _buildRakuDiaryTitle(),
                              // Settings icon
                              GestureDetector(
                                onTap: () => Navigator.pushNamed(context, '/settings'),
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
                        const SizedBox(height: 35), // Reduced from 50 to 35
                        // Infinite Glass Morphism Carousel
                        const InfiniteGlassCarousel(),
                        const SizedBox(height: 50), // Reduced from 80 to 50
                        // Navigation Buttons (animated)
                        AnimatedBuilder(
                          animation: _buttonsAnimation,
                          child: _buildNavigationButtons(),
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, (1 - _buttonsAnimation.value) * 100),
                              child: Opacity(
                                opacity: _buttonsAnimation.value,
                                child: child,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 30), // Reduced from 60 to 30
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
                top: 120 + (_milkDripAnimation.value * MediaQuery.of(context).size.height * 0.4), // Increased from 60 to 120
                left: 0,
                right: 0,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: Image.asset(
                    'assets/images/milk_drip.png',
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
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
        // "Raku" in solid white - reduced size
        const Text(
          'Raku',
          style: TextStyle(
            color: Colors.white,
            fontSize: 40, // Reduced from 48 to 40
            fontWeight: FontWeight.bold,
            letterSpacing: 1.8, // Reduced from 2.0 to 1.8
            fontFamily: 'Montserrat',
          ),
        ),
        // "Diary" with white outline and black fill - reduced size
        Stack(
          children: [
            // Stroke text (white outline)
            Text(
              'Diary',
              style: TextStyle(
                fontSize: 40, // Reduced from 48 to 40
                fontWeight: FontWeight.bold,
                letterSpacing: 1.8, // Reduced from 2.0 to 1.8
                fontFamily: 'Montserrat',
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 3.5 // Reduced from 4 to 3.5
                  ..color = Colors.white,
              ),
            ),
            // Fill text (black inside)
            Text(
              'Diary',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 40, // Reduced from 48 to 40
                fontWeight: FontWeight.bold,
                letterSpacing: 1.8, // Reduced from 2.0 to 1.8
                fontFamily: 'Montserrat',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Column(
      children: [
        // Large Milk Entry Button with icon in center
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8), // Reduced horizontal padding from 24 to 20, vertical from 12 to 8
          child: ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/milk-entry'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 20), // Reduced from 24 to 20
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
                // "Milk" text closer to icon
                const Text(
                  'Milk',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 26, // Reduced from 28 to 26
                    color: Colors.black,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(width: 12), // Reduced from 16 to 12
                // Icon in the center
                Container(
                  width: 90, // Reduced from 100 to 90
                  height: 90, // Reduced from 100 to 90
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0), // Reduced from 20 to 18
                    child: Image.asset(
                      'assets/images/milk_entry.png',
                      fit: BoxFit.contain,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12), // Reduced from 16 to 12
                // "Entry" text closer to icon
                const Text(
                  'Entry',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 26, // Reduced from 28 to 26
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
          padding: const EdgeInsets.symmetric(horizontal: 20.0), // Reduced from 24 to 20
          child: Row(
            children: [
              // Reports Button
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/reports'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16), // Reduced from 20 to 16
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
                        width: 70, // Reduced from 80 to 70
                        height: 70, // Reduced from 80 to 70
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(18.0), // Reduced from 20 to 18
                          child: Image.asset(
                            'assets/images/reports.png',
                            fit: BoxFit.contain,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8), // Reduced from 12 to 8
                      const Text(
                        'Reports',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22, // Reduced from 25 to 22
                          color: Colors.black,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(width: 12), // Reduced from 16 to 12
              
              // Expenses Button
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/expenses'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16), // Reduced from 20 to 16
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
                        width: 70, // Reduced from 80 to 70
                        height: 70, // Reduced from 80 to 70
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(18.0), // Reduced from 20 to 18
                          child: Image.asset(
                            'assets/images/expenses.png',
                            fit: BoxFit.contain,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8), // Reduced from 12 to 8
                      const Text(
                        'Expenses',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22, // Reduced from 25 to 22
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
        const SizedBox(height: 16), // Reduced from 24 to 16
      ],
    );
  }
}

class InfiniteGlassCarousel extends StatefulWidget {
  const InfiniteGlassCarousel({super.key});

  @override
  State<InfiniteGlassCarousel> createState() => _InfiniteGlassCarouselState();
}

class _InfiniteGlassCarouselState extends State<InfiniteGlassCarousel> {
  late PageController _pageController;
  int _currentPage = 0;

  final List<Map<String, String>> _monthsData = [
    {'name': 'JANUARY', 'expense': '1234', 'revenue': '2468', 'profit': '1234'},
    {'name': 'FEBRUARY', 'expense': '1500', 'revenue': '2800', 'profit': '1300'},
    {'name': 'MARCH', 'expense': '1100', 'revenue': '2200', 'profit': '1100'},
    {'name': 'APRIL', 'expense': '1800', 'revenue': '3200', 'profit': '1400'},
    {'name': 'MAY', 'expense': '1600', 'revenue': '2900', 'profit': '1300'},
    {'name': 'JUNE', 'expense': '1400', 'revenue': '2600', 'profit': '1200'},
    {'name': 'JULY', 'expense': '1900', 'revenue': '3400', 'profit': '1500'},
    {'name': 'AUGUST', 'expense': '1700', 'revenue': '3100', 'profit': '1400'},
    {'name': 'SEPTEMBER', 'expense': '1300', 'revenue': '2400', 'profit': '1100'},
    {'name': 'OCTOBER', 'expense': '2000', 'revenue': '3600', 'profit': '1600'},
    {'name': 'NOVEMBER', 'expense': '1800', 'revenue': '3200', 'profit': '1400'},
    {'name': 'DECEMBER', 'expense': '2200', 'revenue': '4000', 'profit': '1800'},
  ];

  @override
  void initState() {
    super.initState();
    
    // Get current month (0-11) and set it as the initial page
    final currentMonth = DateTime.now().month - 1; // Convert to 0-based index
    final initialPage = (_monthsData.length * 1000) + currentMonth; // Add current month to the infinite scroll offset
    
    _pageController = PageController(
      viewportFraction: 0.6, // Reduced from 0.75 to 0.6 to show more of adjacent cards
      initialPage: initialPage, // Start at current month for infinite scroll
    );
    
    // Set current page to current month
    _currentPage = currentMonth;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160, // Reduced from 200 to 160 to prevent overflow
      child: PageView.builder(
        controller: _pageController,
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
                value = (1 - (value.abs() * 0.3)).clamp(0.6, 1.0); // Adjusted for better peek view
              }
              
              return Transform.scale(
                scale: value,
                child: Opacity(
                  opacity: value < 0.8 ? 0.3 : 1.0, // Adjusted opacity for better contrast
                  child: child,
                ),
              );
            },
            child: _buildGlassCard(_monthsData[actualIndex]),
          );
        },
      ),
    );
  }

  Widget _buildGlassCard(Map<String, String> monthData) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4), // Reduced margins to prevent overflow
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16), // Reduced from 20 to 16
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
              borderRadius: BorderRadius.circular(16), // Reduced from 20 to 16
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1.5,
              ),
              boxShadow: [
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
            padding: const EdgeInsets.all(12), // Reduced from 18 to 12
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  monthData['name']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14, // Reduced from 18 to 14
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0, // Reduced from 1.2 to 1.0
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 8), // Reduced from 14 to 8
                _buildDataRow('EXPENSE', monthData['expense']!),
                const SizedBox(height: 4), // Reduced from 8 to 4
                _buildDataRow('REVENUE', monthData['revenue']!),
                const SizedBox(height: 4), // Reduced from 8 to 4
                _buildDataRow('PROFIT', monthData['profit']!, isProfit: true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value, {bool isProfit = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: isProfit ? CrossAxisAlignment.end : CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 10, // Reduced from 13 to 10
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3, // Reduced from 0.5 to 0.3
            fontFamily: 'Montserrat',
          ),
        ),
        Text(
          '$value/-',
          style: TextStyle(
            color: Colors.white,
            fontSize: isProfit ? 22 : 13, // Reduced profit from 30 to 22, others from 17 to 13
            fontWeight: isProfit ? FontWeight.bold : FontWeight.w600,
            fontFamily: 'Montserrat',
          ),
        ),
      ],
    );
  }
}
