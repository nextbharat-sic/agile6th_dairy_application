import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../presentation/login_screen/login_screen_google.dart';
import '../providers/auth_provider.dart';
import '../presentation/registration_screen/registration_screen.dart';
import '../presentation/dashboard_screen/dashboard_screen.dart';
import '../presentation/home_screen/animated_home_screen.dart';
import '../presentation/milk_entry_screen/milk_entry_screen.dart';
import '../presentation/milk_entry_screen/cow_morning_screen.dart';
import '../presentation/milk_entry_screen/buffalo_morning_screen.dart';
import '../presentation/reports_screen/reports_screen.dart';
import '../presentation/expenses_screen/expenses_screen.dart';
import '../presentation/settings_screen/settings_screen.dart';
import '../presentation/settings_screen/profile_screen.dart';
import '../presentation/community_screen/community_screen.dart';
import '../presentation/login_screen/reset_password_screen.dart';

const clientId = '526058541371-1tsa6f523nt73mgsiktb4rarm8ltq5su.apps.googleusercontent.com';

class AppRoutes {
  static const String initial = '/';
  static const String loginScreen = '/login-screen';
  static const String registrationScreen = '/registration-screen';
  static const String dashboard = '/dashboard';
  static const String milkEntry = '/milk-entry';
  static const String cowMorning = '/cow-morning';
  static const String buffaloMorning = '/buffalo-morning';
  static const String reports = '/reports';
  static const String expenses = '/expenses';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String community = '/community';
  static const String resetPassword = '/resetPassword';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => _buildAuthWrapper(context),
    // loginScreen: (context) => const LoginScreen(),
    loginScreen: (context) => const LoginScreenGoogle(clientId: clientId),
    registrationScreen: (context) => const RegistrationScreen(),
    dashboard: (context) => const AnimatedHomeScreen(),
    milkEntry: (context) => const MilkEntryScreen(),
    cowMorning: (context) => const CowMorningScreen(),
    buffaloMorning: (context) => const BuffaloMorningScreen(),
    reports: (context) => const ReportsScreen(),
    expenses: (context) => const ExpensesScreen(),
    settings: (context) => const SettingsScreen(),
    profile: (context) => const ProfileScreen(),
    community: (context) => const CommunityScreen(),
    resetPassword: (context) => const ResetPasswordScreen(),
  };

  static Widget _buildAuthWrapper(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isAuthenticated) {
          return const AnimatedHomeScreen();
        } else {
          return const LoginScreenGoogle(clientId: clientId );
        }
      },
    );
  }
}
