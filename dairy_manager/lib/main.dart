import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'widgets/custom_error_widget.dart';
import 'core/app_export.dart';
import 'l10n/app_localizations.dart';
import 'providers/auth_provider.dart';
import 'providers/reports_provider.dart';
import 'providers/language_provider.dart';
import 'backend/services/income_service.dart';
import 'backend/services/reports_service.dart';
import 'backend/repositories/income_repository.dart';
import 'backend/repositories/expense_repository.dart';
import 'backend/repositories/user_repository.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return CustomErrorWidget(
      errorDetails: details,
    );
  };
  Future.wait([
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
  ]).then((value) {
    runApp(MyApp());
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth Provider
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        
        // Language Provider
        ChangeNotifierProvider(
          create: (_) => LanguageProvider(),
        ),
        
        // Reports Provider with backend services
        ChangeNotifierProvider(
          create: (_) {
            // Initialize Firestore
            final firestore = FirebaseFirestore.instance;
            
            // Initialize repositories
            final incomeRepo = IncomeRepository(firestore);
            final expenseRepo = ExpenseRepository(firestore);
            final userRepo = UserRepository(firestore);
            
            // Initialize services
            final incomeService = IncomeService(
              incomeRepo: incomeRepo, 
              userRepo: userRepo
            );
            
            final reportsService = ReportsService(
              incomeRepo: incomeRepo,
              expenseRepo: expenseRepo,
              userRepo: userRepo,
            );
            
            // Create and return ReportsProvider
            return ReportsProvider(incomeService, reportsService);
          },
        ),
        
        // Add other providers here if needed
        // ChangeNotifierProvider(create: (_) => AnotherProvider()),
      ],
      child: Sizer(builder: (context, orientation, screenType) {
        return Consumer<LanguageProvider>(
          builder: (context, languageProvider, child) {
            return MaterialApp(
              title: 'Dairy Manager',
              theme: AppTheme.lightTheme,
              locale: languageProvider.locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(1.0),
                  ),
                  child: child!,
                );
              },
              debugShowCheckedModeBanner: false,
              routes: AppRoutes.routes,
              initialRoute: AppRoutes.initial,
            );
          },
        );
      }),
    );
  }
}
