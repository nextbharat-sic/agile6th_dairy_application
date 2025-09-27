import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  
  Locale get locale => _locale;
  
  LanguageProvider() {
    _loadSavedLanguage();
  }
  
  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString('language_code') ?? 'en';
      _locale = Locale(languageCode);
      notifyListeners();
    } catch (e) {
      // If SharedPreferences fails, use default locale
      _locale = const Locale('en');
      notifyListeners();
    }
  }
  
  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    
    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
  }
  
  String get currentLanguageName {
    switch (_locale.languageCode) {
      case 'te':
        return 'తెలుగు';
      case 'en':
      default:
        return 'English';
    }
  }
}
