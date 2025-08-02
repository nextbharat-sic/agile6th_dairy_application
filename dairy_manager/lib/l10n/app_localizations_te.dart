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
}
