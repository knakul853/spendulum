import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendulum/constants/theme.dart';
import 'package:spendulum/providers/theme_provider.dart';

class ThemeSelectionScreen extends StatelessWidget {
  const ThemeSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Theme')),
      body: ListView(
        children: [
          _buildThemeItem(context, AppTheme.lightTheme, 'Light'),
          _buildThemeItem(context, AppTheme.darkTheme, 'Dark'),
          _buildThemeItem(context, AppTheme.blueTheme, 'Blue'),
          _buildThemeItem(context, AppTheme.greenTheme, 'Green'),
        ],
      ),
    );
  }

  Widget _buildThemeItem(BuildContext context, ThemeData theme, String themeName) {
    return ListTile(
      title: Text(themeName),
      leading: Icon(Icons.palette, color: theme.primaryColor),
      onTap: () {
        Provider.of<ThemeNotifier>(context, listen: false).setTheme(theme, themeName);
        Navigator.pop(context);
      },
    );
  }
}
