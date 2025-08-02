import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userName = authProvider.userName ?? 'User';
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile row and greeting (blue background)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 36, 16, 0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundImage: AssetImage('assets/images/profile_placeholder.png'),
                  onBackgroundImageError: (exception, stackTrace) {
                    print('Profile image not found: $exception');
                  },
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi, $userName',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 26,
                            ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white, size: 32),
                  onPressed: () {
                    Navigator.pushNamed(context, '/settings');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Inverted milk drip just above the dashboard heading
          Container(
            color: Colors.white,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationX(3.14159),
              child: Image.asset(
                'assets/images/milk_drip.png',
                width: double.infinity,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print('Milk drip image not found: $error');
                  return Container(
                    height: 90,
                    color: Colors.white,
                  );
                },
              ),
            ),
          ),
          // White background starts here, no rounded corners
          Expanded(
            child: Container(
              color: Colors.white,
              width: double.infinity,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dashboard heading
                    Text(
                      'DASHBOARD',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                          ),
                    ),
                    const SizedBox(height: 36),
                    // 2x2 grid of cards
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 32,
                      mainAxisSpacing: 32,
                      childAspectRatio: 0.95,
                      children: [
                        _dashboardCard(
                          context,
                          image: 'assets/images/milk_entry.png',
                          label: 'Milk Entry',
                          onTap: () => Navigator.pushNamed(context, '/milk-entry'),
                        ),
                        _dashboardCard(
                          context,
                          image: 'assets/images/expenses.png',
                          label: 'Expenses',
                          onTap: () => Navigator.pushNamed(context, '/expenses'),
                        ),
                        _dashboardCard(
                          context,
                          image: 'assets/images/reports.png',
                          label: 'Reports',
                          onTap: () => Navigator.pushNamed(context, '/reports'),
                        ),
                        _dashboardCard(
                          context,
                          image: 'assets/images/community_forum.png',
                          label: 'Community Forum',
                          onTap: () => Navigator.pushNamed(context, '/community'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dashboardCard(BuildContext context, {required String image, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        decoration: BoxDecoration(
          color: AppTheme.secondaryColor,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Image.asset(
                  image,
                  fit: BoxFit.contain,
                  width: 70,
                  height: 70,
                  errorBuilder: (context, error, stackTrace) {
                    print('Dashboard card image not found: $image - $error');
                    return Icon(
                      Icons.image_not_supported,
                      size: 48,
                      color: AppTheme.primaryColor,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              label,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
