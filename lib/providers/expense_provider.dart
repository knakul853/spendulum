import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:spendulum/models/expense.dart';
import 'package:spendulum/providers/account_provider.dart';
import 'package:spendulum/services/database/database_helper.dart';
import 'package:spendulum/ui/widgets/logger.dart';
import 'package:spendulum/services/database/tables/expense_table.dart';

/// ExpenseProvider is a class that manages the state and operations related to
/// expenses in the application. It extends ChangeNotifier to allow UI components
/// to listen for changes in the expense data. This class handles loading expenses
/// from a database, adding new expenses, calculating totals, and managing the
/// monthly budget. It also provides methods to retrieve expenses filtered by
/// various criteria such as account ID, date range, and category. The class
/// interacts with the AccountProvider to update account balances when expenses
/// are added. Logging is implemented throughout the class to track operations
/// and errors for better debugging and monitoring.
class ExpenseProvider with ChangeNotifier {
  // List to hold all expenses
  final List<Expense> _expenses = [];
  // Monthly budget for tracking expenses
  double _monthlyBudget = 0.0;
  // Reference to the AccountProvider for account balance updates
  final AccountProvider _accountProvider;

  // Constructor to initialize the ExpenseProvider with an AccountProvider
  ExpenseProvider(this._accountProvider);

  // Getter to retrieve the list of expenses
  List<Expense> get expenses => _expenses;

  // Getter to retrieve the current monthly budget
  double get monthlyBudget => _monthlyBudget;

  // Load expenses from the database
  Future<void> loadExpenses(String accountId, DateTime month) async {
    AppLogger.info(
        'Loading expenses from the database for account $accountId and month $month');
    try {
      // Query all expense records from the database
      final expenseMaps =
          await DatabaseHelper.instance.queryAllRows(ExpensesTable.tableName);
      _expenses.clear(); // Clear existing expenses
      // Map the database records to Expense objects

      AppLogger.info("The expense map is: $expenseMaps");
      // Map the database records to Expense objects, filtering by accountId and month
      _expenses.addAll(expenseMaps.where((map) {
        final expenseDate =
            DateTime.parse(map[ExpensesTable.columnDate] as String);
        return map[ExpensesTable.columnAccountId] == accountId &&
            expenseDate.year == month.year &&
            expenseDate.month == month.month;
      }).map((map) => Expense(
            id: map[ExpensesTable.columnId] as String,
            category: map[ExpensesTable.columnCategory] as String,
            amount: map[ExpensesTable.columnAmount] as double,
            date: DateTime.parse(map[ExpensesTable.columnDate] as String),
            description: map[ExpensesTable.columnDescription] as String,
            accountId: map[ExpensesTable.columnAccountId] as String,
          )));

      // _expenses.addAll(expenseMaps.map((map) => Expense(
      //       id: map[ExpensesTable.columnId] as String,
      //       category: map[ExpensesTable.columnCategory] as String,
      //       amount: map[ExpensesTable.columnAmount] as double,
      //       date: DateTime.parse(map[ExpensesTable.columnDate] as String),
      //       description: map[ExpensesTable.columnDescription] as String,
      //       accountId: map[ExpensesTable.columnAccountId] as String,
      //     )));
      AppLogger.info('Loaded ${_expenses.length} expenses from the database');
      notifyListeners(); // Notify listeners of changes
    } catch (e) {
      AppLogger.error('Error loading expenses from the database', error: e);
    }
  }

  // Add a new expense to the list and database
  Future<void> addExpense(String category, double amount, DateTime date,
      String description, String accountId) async {
    AppLogger.info('Adding new expense: $category, $amount');
    try {
      // Create a new Expense object
      final newExpense = Expense(
        id: const Uuid().v4(), // Generate a unique ID
        category: category,
        amount: amount,
        date: date,
        description: description,
        accountId: accountId,
      );

      // Insert the new expense into the database
      await DatabaseHelper.instance.insert(ExpensesTable.tableName, {
        ExpensesTable.columnId: newExpense.id,
        ExpensesTable.columnCategory: newExpense.category,
        ExpensesTable.columnAmount: newExpense.amount,
        ExpensesTable.columnDate: newExpense.date.toIso8601String(),
        ExpensesTable.columnDescription: newExpense.description,
        ExpensesTable.columnAccountId: newExpense.accountId,
      });

      _expenses.add(newExpense); // Add the new expense to the list
      _accountProvider.updateAccountBalance(
          accountId, -amount); // Update account balance
      notifyListeners(); // Notify listeners of changes
      AppLogger.info('Expense added successfully: ${newExpense.id}');
    } catch (e) {
      AppLogger.error('Error adding expense', error: e);
    }
  }

  // Get total expenses, optionally filtered by account
  double getTotalExpenses({String? accountId}) {
    AppLogger.info('Calculating total expenses');
    return _expenses
        .where((expense) => accountId == null || expense.accountId == accountId)
        .fold(0, (sum, expense) => sum + expense.amount);
  }

  // Get expenses for the current month, optionally filtered by account
  double getCurrentMonthExpenses({String? accountId}) {
    final now = DateTime.now();
    AppLogger.info('Calculating current month expenses');
    return _expenses
        .where((expense) =>
            expense.date.year == now.year &&
            expense.date.month == now.month &&
            (accountId == null || expense.accountId == accountId))
        .fold(0, (sum, expense) => sum + expense.amount);
  }

  // Set monthly budget
  void setMonthlyBudget(double budget) {
    _monthlyBudget = budget; // Update the monthly budget
    notifyListeners(); // Notify listeners of changes
    AppLogger.info('Monthly budget set to: $_monthlyBudget');
  }

  // Get remaining budget for the current month
  double getRemainingBudget({String? accountId}) {
    AppLogger.info('Calculating remaining budget');
    return _monthlyBudget - getCurrentMonthExpenses(accountId: accountId);
  }

  // Get expenses grouped by category
  Map<String, double> getExpensesByCategory({String? accountId}) {
    AppLogger.info('Grouping expenses by category');
    final categoryExpenses = <String, double>{};
    for (var expense in _expenses) {
      if (accountId == null || expense.accountId == accountId) {
        categoryExpenses[expense.category] =
            (categoryExpenses[expense.category] ?? 0) + expense.amount;
      }
    }
    return categoryExpenses;
  }

  // Get expenses for a specific month, optionally filtered by account
  List<Expense> getExpensesForMonth(DateTime month, {String? accountId}) {
    AppLogger.info('Retrieving expenses for month: ${month.toIso8601String()}');
    return _expenses
        .where((expense) =>
            expense.date.year == month.year &&
            expense.date.month == month.month &&
            (accountId == null || expense.accountId == accountId))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Sort by date
  }

  // Get total expenses for a specific month, optionally filtered by account
  double getTotalExpensesForMonth(DateTime month, {String? accountId}) {
    AppLogger.info(
        'Calculating total expenses for month: ${month.toIso8601String()}');
    return getExpensesForMonth(month, accountId: accountId)
        .fold(0, (sum, expense) => sum + expense.amount);
  }

  // Get expenses sorted by date (most recent first)
  List<Expense> get sortedExpenses {
    AppLogger.info('Sorting expenses by date');
    return List.from(_expenses)..sort((a, b) => b.date.compareTo(a.date));
  }

  // Get expenses for a specific date range
  List<Expense> getExpensesForDateRange(DateTime start, DateTime end,
      {String? accountId}) {
    AppLogger.info(
        'Retrieving expenses for date range: ${start.toIso8601String()} to ${end.toIso8601String()}');
    return _expenses
        .where((expense) =>
            expense.date.isAfter(start.subtract(const Duration(days: 1))) &&
            expense.date.isBefore(end.add(const Duration(days: 1))) &&
            (accountId == null || expense.accountId == accountId))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Sort by date
  }

  // Get total expenses for a specific date range
  double getTotalExpensesForDateRange(DateTime start, DateTime end,
      {String? accountId}) {
    AppLogger.info(
        'Calculating total expenses for date range: ${start.toIso8601String()} to ${end.toIso8601String()}');
    return getExpensesForDateRange(start, end, accountId: accountId)
        .fold(0, (sum, expense) => sum + expense.amount);
  }

  // Add multiple expenses to the existing list
  void addAll(List<Expense> expenses) {
    AppLogger.info('Adding multiple expenses: ${expenses.length} items');
    // Add the expenses to your existing list
    this.expenses.addAll(expenses);
    notifyListeners(); // Notify listeners of changes
  }

  Future<List<Expense>> getAllExpenses() async {
    final expenseMaps =
        await DatabaseHelper.instance.queryAllRows(ExpensesTable.tableName);
    return expenseMaps
        .map((map) => Expense(
              id: map[ExpensesTable.columnId] as String,
              category: map[ExpensesTable.columnCategory] as String,
              amount: map[ExpensesTable.columnAmount] as double,
              date: DateTime.parse(map[ExpensesTable.columnDate] as String),
              description: map[ExpensesTable.columnDescription] as String,
              accountId: map[ExpensesTable.columnAccountId] as String,
            ))
        .toList();
  }

  Future<List<Expense>> getExpensesForAccountAndDateRange(
    String accountId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    AppLogger.info(
        'Fetching expenses for account $accountId from $startDate to $endDate');
    try {
      // Construct the SQL query
      final String query = '''
        SELECT * FROM ${ExpensesTable.tableName}
        WHERE ${ExpensesTable.columnAccountId} = ? 
        AND ${ExpensesTable.columnDate} BETWEEN ? AND ?
      ''';

      // Execute the raw query
      final expenseMaps = await DatabaseHelper.instance.rawQuery(
        query,
        [accountId, startDate.toIso8601String(), endDate.toIso8601String()],
      );

      return expenseMaps
          .map((map) => Expense(
                id: map[ExpensesTable.columnId] as String,
                category: map[ExpensesTable.columnCategory] as String,
                amount: map[ExpensesTable.columnAmount] as double,
                date: DateTime.parse(map[ExpensesTable.columnDate] as String),
                description: map[ExpensesTable.columnDescription] as String,
                accountId: map[ExpensesTable.columnAccountId] as String,
              ))
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date)); // Sort by date ascending
    } catch (e) {
      AppLogger.error('Error fetching expenses for date range', error: e);
      return [];
    }
  }
}
