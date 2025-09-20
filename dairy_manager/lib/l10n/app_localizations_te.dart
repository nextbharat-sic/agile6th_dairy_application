// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Telugu (`te`).
class AppLocalizationsTe extends AppLocalizations {
  AppLocalizationsTe([String locale = 'te']) : super(locale);

  @override
  String get settings => 'సెట్టింగ్స్';

  @override
  String get language => 'భాష';

  @override
  String get register => 'నమోదు';

  @override
  String get fullName => 'పూర్తి పేరు';

  @override
  String get email => 'ఇమెయిల్ / సంప్రదింపు సంఖ్య';

  @override
  String get password => 'పాస్వర్డ్';

  @override
  String greeting(Object name) {
    return 'హాయ్, $name';
  }

  @override
  String get welcomeBack => 'మళ్లీ స్వాగతం!';

  @override
  String get milk => 'పాలు';

  @override
  String get entry => 'ఎంట్రీ';

  @override
  String get reports => 'రిపోర్టులు';

  @override
  String get expenses => 'ఖర్చులు';

  @override
  String get expense => 'ఖర్చు';

  @override
  String get revenue => 'ఆదాయం';

  @override
  String get profit => 'లాభం';

  // Milk Entry Screen Translations
  @override
  String get chooseCattle => 'పశువులను ఎంచుకోండి';

  @override
  String get buffalo => 'గేదె';

  @override
  String get cow => 'ఆవు';

  @override
  String get chooseSession => 'సెషన్‌ను ఎంచుకోండి';

  @override
  String get morning => 'ఉదయం';

  @override
  String get evening => 'సాయంత్రం';

  @override
  String get date => 'తేదీ';

  @override
  String get milkL => 'పాలు (లీ)';

  @override
  String get snf => 'SNF';

  @override
  String get fat => 'కొవ్వు';

  @override
  String get costL => 'ఖర్చు/లీ';

  @override
  String get enterCost => 'ఖర్చును నమోదు చేయండి';

  @override
  String get inputText => 'టెక్స్ట్‌ను నమోదు చేయండి';

  @override
  String get required => 'అవసరం';

  @override
  String get ddmmyyyy => 'dd/mm/yyyy';

  // Reports Screen Translations
  @override
  String get weekly => 'వారంలో';

  @override
  String get monthly => 'నెలలో';

  @override
  String get yearly => 'సంవత్సరంలో';

  @override
  String get selectWeek => 'వారాన్ని ఎంచుకోండి';

  @override
  String get milkWeeklyTotal => 'పాల వారపు మొత్తం';

  @override
  String get milkMonthlyTotal => 'పాల నెలవారీ మొత్తం';

  @override
  String get milkYearlyTotal => 'పాల సంవత్సర మొత్తం';

  @override
  String get snfAverage => 'SNF సగటు';

  @override
  String get fatAverage => 'కొవ్వు% సగటు';

  @override
  String get noDataAvailable => 'డేటా అందుబాటులో లేదు';

  // Edit entry screen translations
  @override
  String get today => 'ఈ రోజు';

  @override
  String get yesterday => 'నిన్న';

  @override
  String get dayBeforeYesterday => 'మొన్న';

  @override
  String get snfPercent => 'SNF%';

  @override
  String get fatPercent => 'కొవ్వు%';

  @override
  String get costPerL => 'ధర/లీ';

  // Logout confirmation dialog
  @override
  String get logoutConfirmation => 'మీరు లాగౌట్ చేయాలనుకుంటున్నారా?';

  // Add expense form translations
  @override
  String get addReceiptPhoto => 'రసీదు ఫోటో జోడించండి';
  @override
  String get camera => 'కెమెరా';
  @override
  String get gallery => 'గ్యాలరీ';
  @override
  String get cameraFunctionalityComingSoon => 'కెమెరా ఫంక్షనాలిటీ త్వరలో వస్తుంది';
  @override
  String get galleryFunctionalityComingSoon => 'గ్యాలరీ ఫంక్షనాలిటీ త్వరలో వస్తుంది';
  @override
  String get pleaseEnterAmount => 'దయచేసి మొత్తం నమోదు చేయండి';
  @override
  String get pleaseEnterValidAmount => 'దయచేసి సరైన మొత్తం నమోదు చేయండి';
  @override
  String get descriptionOptional => 'వివరణ (ఐచ్ఛికం)';
  @override
  String get enterExpenseDetails => 'వ్యయ వివరాలను నమోదు చేయండి...';
  @override
  String get receiptAdded => 'రసీదు జోడించబడింది';
  @override
  String get addReceipt => 'రసీదు జోడించండి';

  // Edit entry form translations
  @override
  String get editEntry => 'ఎంట్రీ సవరించండి';

  // Additional missing translations
  @override
  String get todaysIncome => 'ఈ రోజు ఆదాయం';
  @override
  String get buffaloLabel => 'గేదె';
  @override
  String get cowLabel => 'ఆవు';

  // Profile page translations
  @override
  String get emailAddress => 'ఇమెయిల్ చిరునామా';
  @override
  String get phoneNumber => 'ఫోన్ నంబర్';
  @override
  String get age => 'వయస్సు';
  @override
  String get cattleOwned => 'స్వంత పశువులు';
  @override
  String get location => 'స్థానం';

  @override
  String get milkLHeader => 'పాలు(లీ)';

  @override
  String get snfHeader => 'SNF';

  @override
  String get fatHeader => 'కొవ్వు%';

  @override
  String get dayHeader => 'రోజు';

  @override
  String get monday => 'సోమవారం';

  @override
  String get tuesday => 'మంగళవారం';

  @override
  String get wednesday => 'బుధవారం';

  @override
  String get thursday => 'గురువారం';

  @override
  String get friday => 'శుక్రవారం';

  @override
  String get saturday => 'శనివారం';

  @override
  String get sunday => 'ఆదివారం';

  @override
  String get january => 'జనవరి';

  @override
  String get february => 'ఫిబ్రవరి';

  @override
  String get march => 'మార్చి';

  @override
  String get april => 'ఏప్రిల్';

  @override
  String get may => 'మే';

  @override
  String get june => 'జూన్';

  @override
  String get july => 'జులై';

  @override
  String get august => 'ఆగస్టు';

  @override
  String get september => 'సెప్టెంబర్';

  @override
  String get october => 'అక్టోబర్';

  @override
  String get november => 'నవంబర్';

  @override
  String get december => 'డిసెంబర్';

  @override
  String get incomeHeader => 'ఆదాయం';

  @override
  String get expenseHeader => 'ఖర్చు';

  @override
  String get profitHeader => 'లాభం';

  @override
  String get yearlyIncome => 'సంవత్సర ఆదాయం';


  // Income Labels
  @override
  String get weeklyIncome => 'వారపు ఆదాయం';

  @override
  String get monthlyIncome => 'నెలవారీ ఆదాయం';

  // Dropdown Labels
  @override
  String get selectMonth => 'నెల';

  @override
  String get selectYear => 'సంవత్సరాన్ని ఎంచుకోండి';

  @override
  String get month => 'నెల';

  // Expense Categories
  @override
  String get feed => 'ఆహారం';

  @override
  String get labour => 'కార్మికులు';

  @override
  String get healthcare => 'ఆరోగ్య సంరక్షణ';

  @override
  String get utilities => 'ఉపయోగాలు';

  @override
  String get equipment => 'పరికరాలు';

  @override
  String get other => 'ఇతర';

  // Settings Screen Translations
  @override
  String get profile => 'ప్రొఫైల్';

  @override
  String get aboutUs => 'మా గురించి';

  @override
  String get logout => 'లాగౌట్';

  @override
  String get english => 'ఇంగ్లీష్';

  @override
  String get telugu => 'తెలుగు';

  @override
  String get memberSince => 'సభ్యుడైన తేదీ';

  @override
  String get accountCreated => 'ఖాతా సృష్టించబడిన తేదీ';

  // Expenses Screen Translations
  @override
  String get thisMonthsExpenses => 'ఈ నెల ఖర్చులు';

  @override
  String get addNewExpense => 'కొత్త ఖర్చును జోడించండి';

  @override
  String get description => 'వివరణ';

  @override
  String get enterExpenseDescription => 'ఖర్చు వివరణను నమోదు చేయండి';

  @override
  String get amount => 'మొత్తం';

  @override
  String get enterAmount => 'మొత్తాన్ని నమోదు చేయండి';

  @override
  String get category => 'వర్గం';

  @override
  String get selectCategory => 'వర్గాన్ని ఎంచుకోండి';

  @override
  String get addExpense => 'ఖర్చును జోడించండి';

  @override
  String get cancel => 'రద్దు చేయండి';

  // Additional translations for milk entry page
  @override
  String get todaysIncome => 'ఈ రోజు ఆదాయం';

  @override
  String get buffaloLabel => 'గేదె';

  @override
  String get cowLabel => 'ఆవు';

  // Delete confirmation dialog
  @override
  String get deleteExpense => 'ఖర్చును తొలగించండి';

  @override
  String get deleteConfirmation => 'మీరు ఈ ఖర్చును తొలగించాలనుకుంటున్నారా?';

  @override
  String get delete => 'తొలగించండి';

  // Reports screen average text translations
  @override
  String get milkWeeklyTotal => 'పాల వారపు మొత్తం';

  @override
  String get milkMonthlyTotal => 'పాల నెలవారీ మొత్తం';

  @override
  String get milkYearlyTotal => 'పాల సంవత్సర మొత్తం';

  @override
  String get snfAverage => 'SNF సగటు';

  @override
  String get fatAverage => 'కొవ్వు% సగటు';

  @override
  String get noDataAvailable => 'డేటా అందుబాటులో లేదు';
}
