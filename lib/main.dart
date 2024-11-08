import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ui/screens/splash_screen.dart';
import 'providers/expense_provider.dart';
import 'providers/income_provider.dart';
import 'providers/category_provider.dart';
import 'providers/account_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/budget_provider.dart';
import 'providers/reminder_provider.dart';
import 'services/export_service.dart';
import 'db/database_helper.dart';
import 'config/env_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;

void main() {
  // This is required for platform channels
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Add DatabaseHelper Provider
        Provider<DatabaseHelper>(
          create: (_) => DatabaseHelper.instance,
          lazy: false,
        ),

        ChangeNotifierProvider<ReminderProvider>(
          create: (context) => ReminderProvider(),
          lazy: false,
        ),

        // CategoryProvider
        ChangeNotifierProvider<CategoryProvider>(
          lazy: false,
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

        // Add ExportService Provider
        Provider<ExportService>(
          create: (context) => ExportService(
            Provider.of<DatabaseHelper>(context, listen: false),
            Provider.of<ExpenseProvider>(context, listen: false),
            Provider.of<AccountProvider>(context, listen: false),
          ),
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
    final reminderProvider = context.read<ReminderProvider>();
    final exportService = context.read<ExportService>();

    try {
      SecureConfig.initialize();
    } catch (e) {
      print('Error loading .env: $e');
    }

    // Initialize in sequence
    try {
      await Future.wait([
        categoryProvider.loadCategories(),
        budgetProvider.loadBudgets(),
        reminderProvider.initialize(),
      ]);

      // Check for failed export jobs
      await exportService.retryFailedJobs();
    } catch (e) {
      print('Error during initialization: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
