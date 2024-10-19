import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spendulum/constants/theme.dart';

class ThemeNotifier with ChangeNotifier {
  ThemeData _currentTheme = AppTheme.lightTheme;
  int _currentThemeIndex = 0; // Index for customThemes

  ThemeData get currentTheme => _currentTheme;
  int get currentThemeIndex => _currentThemeIndex;


  ThemeNotifier() {
    _loadTheme();
  }

  void setTheme(int index) {
    _currentThemeIndex = index;
    _currentTheme = _getThemeFromIndex(index);
    _saveTheme();
    notifyListeners();
  }

  ThemeData _getThemeFromIndex(int index) {
    if (index == 0) {
      return AppTheme.lightTheme;
    } else if (index == 1) {
      return AppTheme.darkTheme;
    } else {
      return AppTheme.customThemes[index - 2];
    }
  }

  Future<void> _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? themeIndex = prefs.getInt('themeIndex');
    _currentThemeIndex = themeIndex ?? 0; // Default to light theme
    _currentTheme = _getThemeFromIndex(_currentThemeIndex);
    notifyListeners();
  }

  Future<void> _saveTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeIndex', _currentThemeIndex);
  }
}
