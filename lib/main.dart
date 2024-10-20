import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ui/screens/splash_screen.dart';
import 'providers/expense_provider.dart';
import 'providers/income_provider.dart';
import 'providers/category_provider.dart';
import 'providers/account_provider.dart';
import 'providers/theme_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
