import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you'll need to edit this
/// file.
///
/// First, open your project's ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project's Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('te')
  ];

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email / Contact Number'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}'**
  String greeting(Object name);

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get welcomeBack;

  /// No description provided for @milk.
  ///
  /// In en, this message translates to:
  /// **'Milk'**
  String get milk;

  /// No description provided for @entry.
  ///
  /// In en, this message translates to:
  /// **'Entry'**
  String get entry;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'EXPENSE'**
  String get expense;

  /// No description provided for @revenue.
  ///
  /// In en, this message translates to:
  /// **'REVENUE'**
  String get revenue;

  /// No description provided for @profit.
  ///
  /// In en, this message translates to:
  /// **'PROFIT'**
  String get profit;

  // Milk Entry Screen Translations
  /// No description provided for @chooseCattle.
  ///
  /// In en, this message translates to:
  /// **'Choose Cattle'**
  String get chooseCattle;

  /// No description provided for @buffalo.
  ///
  /// In en, this message translates to:
  /// **'Buffalo'**
  String get buffalo;

  /// No description provided for @cow.
  ///
  /// In en, this message translates to:
  /// **'Cow'**
  String get cow;

  /// No description provided for @chooseSession.
  ///
  /// In en, this message translates to:
  /// **'Choose Session'**
  String get chooseSession;

  /// No description provided for @morning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get morning;

  /// No description provided for @evening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get evening;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @milkL.
  ///
  /// In en, this message translates to:
  /// **'Milk (L)'**
  String get milkL;

  /// No description provided for @snf.
  ///
  /// In en, this message translates to:
  /// **'SNF'**
  String get snf;

  /// No description provided for @fat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get fat;

  /// No description provided for @costL.
  ///
  /// In en, this message translates to:
  /// **'Cost/L'**
  String get costL;

  /// No description provided for @enterCost.
  ///
  /// In en, this message translates to:
  /// **'Enter the cost'**
  String get enterCost;

  /// No description provided for @inputText.
  ///
  /// In en, this message translates to:
  /// **'Input Text'**
  String get inputText;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @ddmmyyyy.
  ///
  /// In en, this message translates to:
  /// **'dd/mm/yyyy'**
  String get ddmmyyyy;

  // Reports Screen Translations
  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// No description provided for @selectWeek.
  ///
  /// In en, this message translates to:
  /// **'Select Week'**
  String get selectWeek;

  /// No description provided for @milkWeeklyAverage.
  ///
  /// In en, this message translates to:
  /// **'Milk Weekly Average : 148 L\nSNF Weekly Average : 12\nFat% Weekly Average : 20%'**
  String get milkWeeklyAverage;

  /// No description provided for @milkMonthlyAverage.
  ///
  /// In en, this message translates to:
  /// **'Milk Monthly Average : 520 L\nSNF Monthly Average : 20\nFat% Monthly Average : 20%'**
  String get milkMonthlyAverage;

  /// No description provided for @milkYearlyAverage.
  ///
  /// In en, this message translates to:
  /// **'Milk Yearly Average : 6000 L\nSNF Yearly Average : 20\nFat% Yearly Average : 20%'**
  String get milkYearlyAverage;

  /// No description provided for @milkLHeader.
  ///
  /// In en, this message translates to:
  /// **'Milk(L)'**
  String get milkLHeader;

  /// No description provided for @snfHeader.
  ///
  /// In en, this message translates to:
  /// **'SNF'**
  String get snfHeader;

  /// No description provided for @fatHeader.
  ///
  /// In en, this message translates to:
  /// **'Fat%'**
  String get fatHeader;

  /// No description provided for @incomeHeader.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get incomeHeader;

  /// No description provided for @expenseHeader.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expenseHeader;

  /// No description provided for @profitHeader.
  ///
  /// In en, this message translates to:
  /// **'Profit'**
  String get profitHeader;

  /// No description provided for @yearlyIncome.
  ///
  /// In en, this message translates to:
  /// **'YEARLY INCOME'**
  String get yearlyIncome;

  // Month Names
  String get january;
  String get february;
  String get march;
  String get april;
  String get may;
  String get june;
  String get july;
  String get august;
  String get september;
  String get october;
  String get november;
  String get december;

  // Income Labels
  String get weeklyIncome;
  String get monthlyIncome;

  // Dropdown Labels
  String get selectMonth;
  String get selectYear;
  String get month;

  // Expense Categories
  String get feed;
  String get labour;
  String get healthcare;
  String get utilities;
  String get equipment;
  String get other;

  // Settings Screen Translations
  String get profile;
  String get aboutUs;
  String get logout;
  String get english;
  String get telugu;
  String get memberSince;
  String get accountCreated;

  // Expenses Screen Translations
  /// No description provided for @thisMonthsExpenses.
  ///
  /// In en, this message translates to:
  /// **'This Month\'s Expenses'**
  String get thisMonthsExpenses;

  /// No description provided for @addNewExpense.
  ///
  /// In en, this message translates to:
  /// **'Add New Expense'**
  String get addNewExpense;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @enterExpenseDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter expense description'**
  String get enterExpenseDescription;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @enterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get enterAmount;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// No description provided for @addExpense.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addExpense;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'te'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'te': return AppLocalizationsTe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
