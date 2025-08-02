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
}
