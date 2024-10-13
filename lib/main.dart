import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ui/screens/splash_screen.dart';
import 'providers/expense_provider.dart';
import 'providers/income_provider.dart';
import 'providers/category_provider.dart';
import 'providers/account_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      ],
      child: MaterialApp(
        title: 'Expense Tracker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Colors.red, // Set background color here
          ),
        ),
        home: const SplashScreen(), // Start with the SplashScreen
        debugShowCheckedModeBanner: false, // Disable debug banner
      ),
    );
  }
}
