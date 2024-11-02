import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ui/screens/splash_screen.dart';
import 'providers/expense_provider.dart';
import 'providers/income_provider.dart';
import 'providers/category_provider.dart';
import 'providers/account_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/budget_provider.dart';

void main() {
  runApp(const MyApp());
}

/// Main entry point for the application, built with Flutter and using the Provider package for state management.
/// The app starts with a splash screen and then navigates to the main home screen with a bottom navigation bar.
/// Key features include transaction tracking, budget management, account management, and customizable themes.

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // CategoryProvider
        ChangeNotifierProvider(
          create: (context) {
            final provider = CategoryProvider();
            provider.loadCategories();
            return provider;
          },
        ),

        // AccountProvider
        ChangeNotifierProvider(create: (context) => AccountProvider()),

        // BudgetProvider
        ChangeNotifierProvider(
          create: (context) {
            final provider = BudgetProvider();
            provider.loadBudgets();
            return provider;
          },
        ),

        // ExpenseProvider with both AccountProvider and BudgetProvider
        ChangeNotifierProxyProvider2<AccountProvider, BudgetProvider,
            ExpenseProvider>(
          create: (context) => ExpenseProvider(
            Provider.of<AccountProvider>(context, listen: false),
            Provider.of<BudgetProvider>(context, listen: false),
          ),
          // Maintain the previous state when updating
          update: (context, accountProvider, budgetProvider, previous) {
            if (previous == null) {
              return ExpenseProvider(accountProvider, budgetProvider);
            }
            // Return the previous instance instead of creating a new one
            return previous..updateProviders(accountProvider, budgetProvider);
          },
          lazy: false,
        ),

        // IncomeProvider
        ChangeNotifierProxyProvider<AccountProvider, IncomeProvider>(
          create: (context) => IncomeProvider(
            Provider.of<AccountProvider>(context, listen: false),
          ),
          update: (context, accountProvider, previous) {
            if (previous == null) {
              return IncomeProvider(accountProvider);
            }
            return previous..updateAccountProvider(accountProvider);
          },
          lazy: false,
        ),

        // ThemeProvider
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Expense Tracker',
            theme: themeProvider.currentTheme,
            home: const SplashScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
