import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/theme.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _currentTheme = AppTheme.lightTheme;
  int _currentThemeIndex = 0;

  ThemeData get currentTheme => _currentTheme;
  int get currentThemeIndex => _currentThemeIndex;

  ThemeProvider() {
    _loadTheme();
  }

  void setTheme(int index) {
    _currentThemeIndex = index;
    _currentTheme = AppTheme.getThemeFromIndex(index);
    _saveTheme();
    notifyListeners();
  }

  Future<void> _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _currentThemeIndex = prefs.getInt('themeIndex') ?? 1;
    _currentTheme = AppTheme.getThemeFromIndex(_currentThemeIndex);
    notifyListeners();
  }

  Future<void> _saveTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeIndex', _currentThemeIndex);
  }
}
