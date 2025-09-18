import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/app_export.dart';
import '../providers/navigation_provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen/animated_home_screen.dart';
import 'milk_entry_screen/milk_entry_screen.dart';
import 'reports_screen/reports_screen.dart';
import 'expenses_screen/expenses_screen.dart';
import 'settings_screen/settings_screen.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (_) => ExpensesProvider(
            ExpenseService(
              expenseRepo: ExpenseRepository(FirebaseFirestore.instance),
            ),
          ),
        ),
      ],
      child: const MainNavigationView(),
    );
  }
}

class MainNavigationView extends StatelessWidget {
  const MainNavigationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, child) {
        return Scaffold(
          body: IndexedStack(
            index: navigationProvider.currentIndex,
            children: const [
              AnimatedHomeScreen(),
              MilkEntryScreen(),
              ReportsScreen(),
              ExpensesScreen(),
              SettingsScreen(),
            ],
          ),
          bottomNavigationBar: _buildBottomNavigationBar(context, navigationProvider),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, NavigationProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                icon: Icons.dashboard_rounded,
                label: 'Dashboard',
                index: 0,
                provider: provider,
              ),
              _buildNavItem(
                context,
                icon: Icons.add_circle_outline_rounded,
                label: 'Milk Entry',
                index: 1,
                provider: provider,
              ),
              _buildNavItem(
                context,
                icon: Icons.bar_chart_rounded,
                label: 'Reports',
                index: 2,
                provider: provider,
              ),
              _buildNavItem(
                context,
                icon: Icons.account_balance_wallet_rounded,
                label: 'Expenses',
                index: 3,
                provider: provider,
              ),
              _buildNavItem(
                context,
                icon: Icons.settings_rounded,
                label: 'Settings',
                index: 4,
                provider: provider,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
    required NavigationProvider provider,
  }) {
    final isSelected = provider.currentIndex == index;
    final colorScheme = AppTheme.lightTheme.colorScheme;

    return GestureDetector(
      onTap: () => provider.setCurrentIndex(index),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected 
            ? colorScheme.primary.withValues(alpha: 0.1)
            : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24.sp,
              color: isSelected 
                ? colorScheme.primary
                : colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            SizedBox(height: 0.5.h),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                color: isSelected 
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 