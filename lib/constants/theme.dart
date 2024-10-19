import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    colorScheme: ColorScheme.light(
      secondary: Colors.teal,
    ),
    scaffoldBackgroundColor: Colors.white,
    fontFamily: 'Roboto',
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.teal,
    colorScheme: ColorScheme.dark(
      secondary: Colors.blue,
    ),
    scaffoldBackgroundColor: Colors.black,
    fontFamily: 'Roboto',
  );

  static ThemeData blueTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    colorScheme: ColorScheme.light(
      secondary: Colors.lightBlue,
    ),
    scaffoldBackgroundColor: Colors.blue[50]!,
    fontFamily: 'Roboto',
  );

  static ThemeData greenTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.green,
    colorScheme: ColorScheme.light(
      secondary: Colors.lightGreen,
    ),
    scaffoldBackgroundColor: Colors.green[50]!,
    fontFamily: 'Roboto',
  );
}
