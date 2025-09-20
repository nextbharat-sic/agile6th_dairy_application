// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get register => 'Register';

  @override
  String get fullName => 'Full Name';

  @override
  String get email => 'Email / Contact Number';

  @override
  String get password => 'Password';

  @override
  String greeting(Object name) {
    return 'Hi, $name';
  }

  @override
  String get welcomeBack => 'Welcome back!';

  @override
  String get milk => 'Milk';

  @override
  String get entry => 'Entry';

  @override
  String get reports => 'Reports';

  @override
  String get expenses => 'Expenses';

  @override
  String get expense => 'EXPENSE';

  @override
  String get revenue => 'REVENUE';

  @override
  String get profit => 'PROFIT';

  // Milk Entry Screen Translations
  @override
  String get chooseCattle => 'Choose Cattle';

  @override
  String get buffalo => 'Buffalo';

  @override
  String get cow => 'Cow';

  @override
  String get chooseSession => 'Choose Session';

  @override
  String get morning => 'Morning';

  @override
  String get evening => 'Evening';

  @override
  String get date => 'Date';

  @override
  String get milkL => 'Milk (L)';

  @override
  String get snf => 'SNF';

  @override
  String get fat => 'Fat';

  @override
  String get costL => 'Cost/L';

  @override
  String get enterCost => 'Enter the cost';

  @override
  String get inputText => 'Input Text';

  @override
  String get required => 'Required';

  @override
  String get ddmmyyyy => 'dd/mm/yyyy';

  // Reports Screen Translations
  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get yearly => 'Yearly';

  @override
  String get selectWeek => 'Select Week';

  @override
  String get milkWeeklyAverage => 'Milk Weekly Average : 148 L\nSNF Weekly Average : 12\nFat% Weekly Average : 20%';

  @override
  String get milkMonthlyAverage => 'Milk Monthly Average : 520 L\nSNF Monthly Average : 20\nFat% Monthly Average : 20%';

  @override
  String get milkYearlyAverage => 'Milk Yearly Average : 6000 L\nSNF Yearly Average : 20\nFat% Yearly Average : 20%';

  @override
  String get milkLHeader => 'Milk(L)';

  @override
  String get snfHeader => 'SNF';

  @override
  String get fatHeader => 'Fat%';

  @override
  String get dayHeader => 'DAY';

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  @override
  String get january => 'January';

  @override
  String get february => 'February';

  @override
  String get march => 'March';

  @override
  String get april => 'April';

  @override
  String get may => 'May';

  @override
  String get june => 'June';

  @override
  String get july => 'July';

  @override
  String get august => 'August';

  @override
  String get september => 'September';

  @override
  String get october => 'October';

  @override
  String get november => 'November';

  @override
  String get december => 'December';

  @override
  String get incomeHeader => 'Income';

  @override
  String get expenseHeader => 'Expense';

  @override
  String get profitHeader => 'Profit';

  @override
  String get yearlyIncome => 'YEARLY INCOME';


  // Income Labels
  @override
  String get weeklyIncome => 'WEEKLY INCOME';

  @override
  String get monthlyIncome => 'MONTHLY INCOME';

  // Dropdown Labels
  @override
  String get selectMonth => 'Month';

  @override
  String get selectYear => 'Select Year';

  @override
  String get month => 'Month';

  // Expense Categories
  @override
  String get feed => 'Feed';

  @override
  String get labour => 'Labour';

  @override
  String get healthcare => 'Healthcare';

  @override
  String get utilities => 'Utilities';

  @override
  String get equipment => 'Equipment';

  @override
  String get other => 'Other';

  // Settings Screen Translations
  @override
  String get profile => 'Profile';

  @override
  String get aboutUs => 'About Us';

  @override
  String get logout => 'Logout';

  @override
  String get english => 'English';

  @override
  String get telugu => 'Telugu';

  @override
  String get memberSince => 'Member since';

  @override
  String get accountCreated => 'Account Created';

  // Expenses Screen Translations
  @override
  String get thisMonthsExpenses => 'This Month\'s Expenses';

  @override
  String get addNewExpense => 'Add New Expense';

  @override
  String get description => 'Description';

  @override
  String get enterExpenseDescription => 'Enter expense description';

  @override
  String get amount => 'Amount';

  @override
  String get enterAmount => 'Enter amount';

  @override
  String get category => 'Category';

  @override
  String get selectCategory => 'Select Category';

  @override
  String get addExpense => 'Add Expense';

  @override
  String get cancel => 'Cancel';

  // Additional translations for milk entry page
  @override
  String get todaysIncome => 'TODAY\'S INCOME';

  @override
  String get buffaloLabel => 'Buffalo';

  @override
  String get cowLabel => 'Cow';

  // Delete confirmation dialog
  @override
  String get deleteExpense => 'Delete Expense';

  @override
  String get deleteConfirmation => 'Are you sure you want to delete this expense?';

  @override
  String get delete => 'Delete';

  // Reports screen average text translations
  @override
  String get milkWeeklyTotal => 'Milk Weekly Total';

  @override
  String get milkMonthlyTotal => 'Milk Monthly Total';

  @override
  String get milkYearlyTotal => 'Milk Yearly Total';

  @override
  String get snfAverage => 'SNF Average';

  @override
  String get fatAverage => 'Fat% Average';

  @override
  String get noDataAvailable => 'No data available';
}
