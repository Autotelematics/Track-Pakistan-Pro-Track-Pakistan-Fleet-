import 'package:flutter/material.dart';
import 'package:trackerapp/utils/preference_keys.dart';
import 'package:trackerapp/utils/shared_preference.dart';

class LanguageProvider extends ChangeNotifier {
  static const supportedLocales = [
    Locale('en'),
    Locale('ur'),
    Locale('ar'),
  ];

  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  Future<void> loadSavedLocale() async {
    final savedCode = MySharedPreferences.getString(appLanguageCodeKey).trim();
    _locale = _localeForCode(savedCode);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale.languageCode == locale.languageCode) {
      return;
    }
    _locale = _localeForCode(locale.languageCode);
    await MySharedPreferences.setString(
      appLanguageCodeKey,
      _locale.languageCode,
    );
    notifyListeners();
  }

  Locale _localeForCode(String code) {
    return supportedLocales.firstWhere(
      (locale) => locale.languageCode == code,
      orElse: () => const Locale('en'),
    );
  }
}
