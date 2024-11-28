import 'package:flutter/material.dart';

class LanguageProvider with ChangeNotifier {
  Locale _locale = Locale('en', 'US');

  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';
  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }
  void changeLanguage(String languageCode) {
    if (languageCode == 'ar') {
      _locale = Locale('ar', 'EG');
    } else {
      _locale = Locale('en', 'US');
    }
    notifyListeners();
  }
}