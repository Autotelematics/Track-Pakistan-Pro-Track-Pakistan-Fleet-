import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  int _selectedIndex = 2; // 0 = Light, 1 = Dark, 2 = System

  ThemeMode get themeMode => _themeMode;
  int get selectedIndex => _selectedIndex;

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('themeMode') ?? 'system';

    switch (saved) {
      case 'dark':
        _themeMode = ThemeMode.dark;
        _selectedIndex = 1;
        break;
      case 'light':
        _themeMode = ThemeMode.light;
        _selectedIndex = 0;
        break;
      default:
        _themeMode = ThemeMode.system;
        _selectedIndex = 2;
    }
    notifyListeners();
  }

  Future<void> setTheme(ThemeMode mode, int index) async {
    _themeMode = mode;
    _selectedIndex = index;

    final prefs = await SharedPreferences.getInstance();
    String modeString;
    switch (mode) {
      case ThemeMode.dark:
        modeString = 'dark';
        break;
      case ThemeMode.light:
        modeString = 'light';
        break;
      default:
        modeString = 'system';
    }

    await prefs.setString('themeMode', modeString);
    notifyListeners();
  }
}
