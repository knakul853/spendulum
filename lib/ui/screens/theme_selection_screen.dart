import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendulum/constants/theme.dart';
import 'package:spendulum/providers/theme_provider.dart';

class ThemeSelectionScreen extends StatefulWidget {
  const ThemeSelectionScreen({Key? key}) : super(key: key);

  @override
  State<ThemeSelectionScreen> createState() => _ThemeSelectionScreenState();
}

class _ThemeSelectionScreenState extends State<ThemeSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final themeIndex = themeNotifier.currentThemeIndex;

    return Scaffold(
      appBar: AppBar(title: const Text('Theme Selection')),
      body: ListView.builder(
        itemCount: AppTheme.customThemes.length + 2,
        itemBuilder: (context, index) {
          final theme = AppTheme.getThemeFromIndex(index);
          final themeName = AppTheme.getThemeNameFromIndex(index);
          return ListTile(
            title: Text(themeName),
            leading: CircleAvatar(
                backgroundColor: theme?.primaryColor ?? Colors.grey),
            onTap: () {
              themeNotifier.setTheme(index);
            },
            trailing: Icon(themeIndex == index ? Icons.check : null),
          );
        },
      ),
    );
  }
}

// Extension methods for AppTheme - defined outside any class
extension AppThemeExtension on AppTheme {
  static ThemeData? getThemeFromIndex(int index) {
    try {
      if (index == 0) {
        return AppTheme.lightTheme;
      } else if (index == 1) {
        return AppTheme.darkTheme;
      } else {
        return AppTheme.customThemes[index - 2];
      }
    } catch (e) {
      print("Error getting theme from index: $e");
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
