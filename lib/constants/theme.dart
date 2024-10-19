import 'package:flutter/material.dart';
import 'package:spendulum/constants/app_colors.dart';
import 'package:spendulum/constants/theme_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    colorScheme: ColorScheme.light(
      secondary: AppColors.secondary,
    ),
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Roboto',
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.secondary,
    colorScheme: ColorScheme.dark(
      secondary: AppColors.primary,
    ),
    scaffoldBackgroundColor: AppColors.background, 
    fontFamily: 'Roboto',
  );

  static List<ThemeData> customThemes = [
    ThemeData(
      brightness: Brightness.light,
      primaryColor: ThemeColors.palette1.primary,
      colorScheme: ColorScheme.light(
        secondary: ThemeColors.palette1.secondary,
      ),
      scaffoldBackgroundColor: ThemeColors.palette1.background,
      fontFamily: 'Roboto',
    ),
    ThemeData(
      brightness: Brightness.light,
      primaryColor: ThemeColors.palette2.primary,
      colorScheme: ColorScheme.light(
        secondary: ThemeColors.palette2.secondary,
      ),
      scaffoldBackgroundColor: ThemeColors.palette2.background,
      fontFamily: 'Roboto',
    ),
    ThemeData(
      brightness: Brightness.light,
      primaryColor: ThemeColors.palette3.primary,
      colorScheme: ColorScheme.light(
        secondary: ThemeColors.palette3.secondary,
      ),
      scaffoldBackgroundColor: ThemeColors.palette3.background,
      fontFamily: 'Roboto',
    ),
    ThemeData(
      brightness: Brightness.light,
      primaryColor: ThemeColors.palette4.primary,
      colorScheme: ColorScheme.light(
        secondary: ThemeColors.palette4.secondary,
      ),
      scaffoldBackgroundColor: ThemeColors.palette4.background,
      fontFamily: 'Roboto',
    ),
    ThemeData(
      brightness: Brightness.light,
      primaryColor: ThemeColors.palette5.primary,
      colorScheme: ColorScheme.light(
        secondary: ThemeColors.palette5.secondary,
      ),
      scaffoldBackgroundColor: ThemeColors.palette5.background,
      fontFamily: 'Roboto',
    ),
    ThemeData(
      brightness: Brightness.light,
      primaryColor: ThemeColors.palette6.primary,
      colorScheme: ColorScheme.light(
        secondary: ThemeColors.palette6.secondary,
      ),
      scaffoldBackgroundColor: ThemeColors.palette6.background,
      fontFamily: 'Roboto',
    ),
    ThemeData(
      brightness: Brightness.light,
      primaryColor: ThemeColors.palette7.primary,
      colorScheme: ColorScheme.light(
        secondary: ThemeColors.palette7.secondary,
      ),
      scaffoldBackgroundColor: ThemeColors.palette7.background,
      fontFamily: 'Roboto',
    ),
    ThemeData(
      brightness: Brightness.light,
      primaryColor: ThemeColors.palette8.primary,
      colorScheme: ColorScheme.light(
        secondary: ThemeColors.palette8.secondary,
      ),
      scaffoldBackgroundColor: ThemeColors.palette8.background,
      fontFamily: 'Roboto',
    ),
  ];

  static ThemeData? getThemeFromIndex(int index) {
    try {
      if (index == 0) {
        return lightTheme;
      } else if (index == 1) {
        return darkTheme;
      } else {
        return customThemes[index - 2];
      }
    } catch (e) {
      print('Error getting theme from index: $e');
      return null;
    }
  }

  static String getThemeNameFromIndex(int index) {
    if (index == 0) {
      return 'Light';
    } else if (index == 1) {
      return 'Dark';
    } else {
      return 'Custom ${index - 1}';
    }
  }
}
