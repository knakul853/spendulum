import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spendulum/constants/theme.dart';

class ThemeNotifier with ChangeNotifier {
  ThemeData _currentTheme = AppTheme.lightTheme;
  String _currentThemeName = 'Light';

  ThemeData get currentTheme => _currentTheme;
  String get currentThemeName => _currentThemeName;

  ThemeNotifier() {
    _loadTheme();
  }

  void setTheme(ThemeData theme, String themeName) {
    _currentTheme = theme;
    _currentThemeName = themeName;
    _saveTheme();
    notifyListeners();
  }

  Future<void> _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? themeName = prefs.getString('theme');
    if (themeName != null) {
      switch (themeName) {
        case 'Dark':
          _currentTheme = AppTheme.darkTheme;
          _currentThemeName = 'Dark';
          break;
        case 'Blue':
          _currentTheme = AppTheme.blueTheme;
          _currentThemeName = 'Blue';
          break;
        case 'Green':
          _currentTheme = AppTheme.greenTheme;
          _currentThemeName = 'Green';
          break;
        default:
          _currentTheme = AppTheme.lightTheme;
          _currentThemeName = 'Light';
      }
    }
    notifyListeners();
  }

  Future<void> _saveTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', _currentThemeName);
  }
}
