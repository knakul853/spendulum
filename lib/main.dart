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

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // CategoryProvider
        ChangeNotifierProvider<CategoryProvider>(
          lazy: false, // This ensures immediate creation
          create: (context) => CategoryProvider(),
        ),

        // AccountProvider
        ChangeNotifierProvider(create: (context) => AccountProvider()),

        // BudgetProvider
        ChangeNotifierProvider(
          create: (context) => BudgetProvider(),
          lazy: false,
        ),

        // ExpenseProvider with both AccountProvider and BudgetProvider
        ChangeNotifierProxyProvider2<AccountProvider, BudgetProvider,
            ExpenseProvider>(
          create: (context) => ExpenseProvider(
            Provider.of<AccountProvider>(context, listen: false),
            Provider.of<BudgetProvider>(context, listen: false),
          ),
          update: (context, accountProvider, budgetProvider, previous) {
            if (previous == null) {
              return ExpenseProvider(accountProvider, budgetProvider);
            }
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
            home: const InitializationWrapper(child: SplashScreen()),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

// New widget to handle initialization
class InitializationWrapper extends StatefulWidget {
  final Widget child;

  const InitializationWrapper({Key? key, required this.child})
      : super(key: key);

  @override
  State<InitializationWrapper> createState() => _InitializationWrapperState();
}

class _InitializationWrapperState extends State<InitializationWrapper> {
  @override
  void initState() {
    super.initState();
    _initializeProviders();
  }

  Future<void> _initializeProviders() async {
    // Get providers
    final categoryProvider = context.read<CategoryProvider>();
    final budgetProvider = context.read<BudgetProvider>();

    // Initialize in sequence
    await categoryProvider.loadCategories();
    await budgetProvider.loadBudgets();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
