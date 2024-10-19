import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ui/screens/splash_screen.dart';
import 'providers/expense_provider.dart';
import 'providers/income_provider.dart';
import 'providers/category_provider.dart';
import 'providers/account_provider.dart';
import 'providers/theme_provider.dart'; // Import ThemeNotifier
import 'constants/theme_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedTheme = 0;

  void _changeTheme(int index) {
    setState(() {
      _selectedTheme = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeColors.palette3; // Default theme

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CategoryProvider()),
        ChangeNotifierProvider(create: (context) => AccountProvider()),
        ChangeNotifierProxyProvider<AccountProvider, ExpenseProvider>(
          create: (context) => ExpenseProvider(
              Provider.of<AccountProvider>(context, listen: false)),
          update: (context, accountProvider, previous) =>
              ExpenseProvider(accountProvider)
                ..addAll(previous?.expenses ?? []),
        ),
        ChangeNotifierProxyProvider<AccountProvider, IncomeProvider>(
          create: (context) => IncomeProvider(
              Provider.of<AccountProvider>(context, listen: false)),
          update: (context, accountProvider, previous) =>
              IncomeProvider(accountProvider)..addAll(previous?.incomes ?? []),
        ),
        ChangeNotifierProvider(create: (context) => ThemeNotifier()), // Add ThemeNotifier provider
      ],
      child: MaterialApp(
        title: 'Expense Tracker',
        theme: ThemeData(
          primaryColor: theme.primary,
          colorScheme: ColorScheme.fromSwatch(
              primarySwatch: MaterialColor(theme.primary.value, {
            50: theme.primary.withOpacity(0.1),
            100: theme.primary.withOpacity(0.2),
            200: theme.primary.withOpacity(0.3),
            300: theme.primary.withOpacity(0.4),
            400: theme.primary.withOpacity(0.5),
            500: theme.primary,
            600: theme.primary.withOpacity(0.7),
            700: theme.primary.withOpacity(0.8),
            800: theme.primary.withOpacity(0.9),
            900: theme.primary,
          })),
          scaffoldBackgroundColor: theme.background,
          textTheme: TextTheme(
            bodyMedium: TextStyle(color: theme.getTextColor()),
            headlineMedium: TextStyle(color: theme.getTextColor()),
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: theme.secondary,
          ),
        ),
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
