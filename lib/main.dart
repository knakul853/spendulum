import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'providers/expense_provider.dart';
import 'providers/category_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ExpenseProvider()),
        ChangeNotifierProvider(
            create: (context) =>
                CategoryProvider()), // Add CategoryProvider here
      ],
      child: MaterialApp(
        title: 'Expense Tracker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const SplashScreen(), // Start with the SplashScreen
        debugShowCheckedModeBanner: false, // Disable debug banner
      ),
    );
  }
}
