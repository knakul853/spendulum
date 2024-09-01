import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:spendulum/models/expense.dart';
import 'package:spendulum/providers/account_provider.dart';
import 'package:spendulum/services/database/database_helper.dart';
import 'package:spendulum/ui/widgets/logger.dart';
import 'package:spendulum/services/database/tables/expense_table.dart';

class ExpenseProvider with ChangeNotifier {
  final List<Expense> _expenses = [];
  double _monthlyBudget = 0.0;
  final AccountProvider _accountProvider;

  ExpenseProvider(this._accountProvider);

  List<Expense> get expenses => _expenses;
  double get monthlyBudget => _monthlyBudget;

  // Load expenses from the database
  Future<void> loadExpenses() async {
    AppLogger.info('Loading expenses');
    try {
      final expenseMaps =
          await DatabaseHelper.instance.queryAllRows(ExpensesTable.tableName);
      _expenses.clear();
      _expenses.addAll(expenseMaps.map((map) => Expense(
            id: map[ExpensesTable.columnId] as String,
            category: map[ExpensesTable.columnCategory] as String,
            amount: map[ExpensesTable.columnAmount] as double,
            date: DateTime.parse(map[ExpensesTable.columnDate] as String),
            description: map[ExpensesTable.columnDescription] as String,
            accountId: map[ExpensesTable.columnAccountId] as String,
          )));
      AppLogger.info('Loaded ${_expenses.length} expenses');
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error loading expenses', error: e);
    }
  }

  // Add a new expense
  Future<void> addExpense(String category, double amount, DateTime date,
      String description, String accountId) async {
    AppLogger.info('Adding new expense: $category, $amount');
    try {
      final newExpense = Expense(
        id: const Uuid().v4(),
        category: category,
        amount: amount,
        date: date,
        description: description,
        accountId: accountId,
      );

      // Insert into database
      await DatabaseHelper.instance.insert(ExpensesTable.tableName, {
        ExpensesTable.columnId: newExpense.id,
        ExpensesTable.columnCategory: newExpense.category,
        ExpensesTable.columnAmount: newExpense.amount,
        ExpensesTable.columnDate: newExpense.date.toIso8601String(),
        ExpensesTable.columnDescription: newExpense.description,
        ExpensesTable.columnAccountId: newExpense.accountId,
      });

      _expenses.add(newExpense);
      _accountProvider.updateAccountBalance(accountId, -amount);
      notifyListeners();
      AppLogger.info('Expense added successfully: ${newExpense.id}');
    } catch (e) {
      AppLogger.error('Error adding expense', error: e);
    }
  }

  // Get total expenses, optionally filtered by account
  double getTotalExpenses({String? accountId}) {
    return _expenses
        .where((expense) => accountId == null || expense.accountId == accountId)
        .fold(0, (sum, expense) => sum + expense.amount);
  }

  // Get expenses for the current month, optionally filtered by account
  double getCurrentMonthExpenses({String? accountId}) {
    final now = DateTime.now();
    return _expenses
        .where((expense) =>
            expense.date.year == now.year &&
            expense.date.month == now.month &&
            (accountId == null || expense.accountId == accountId))
        .fold(0, (sum, expense) => sum + expense.amount);
  }

  // Set monthly budget
  void setMonthlyBudget(double budget) {
    _monthlyBudget = budget;
    notifyListeners();
  }

  // Get remaining budget for the current month
  double getRemainingBudget({String? accountId}) {
    return _monthlyBudget - getCurrentMonthExpenses(accountId: accountId);
  }

  // Get expenses grouped by category
  Map<String, double> getExpensesByCategory({String? accountId}) {
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
    return _expenses
        .where((expense) =>
            expense.date.year == month.year &&
            expense.date.month == month.month &&
            (accountId == null || expense.accountId == accountId))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Get total expenses for a specific month, optionally filtered by account
  double getTotalExpensesForMonth(DateTime month, {String? accountId}) {
    return getExpensesForMonth(month, accountId: accountId)
        .fold(0, (sum, expense) => sum + expense.amount);
  }

  // Get expenses sorted by date (most recent first)
  List<Expense> get sortedExpenses {
    return List.from(_expenses)..sort((a, b) => b.date.compareTo(a.date));
  }

  // Get expenses for a specific date range
  List<Expense> getExpensesForDateRange(DateTime start, DateTime end,
      {String? accountId}) {
    return _expenses
        .where((expense) =>
            expense.date.isAfter(start.subtract(const Duration(days: 1))) &&
            expense.date.isBefore(end.add(const Duration(days: 1))) &&
            (accountId == null || expense.accountId == accountId))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Get total expenses for a specific date range
  double getTotalExpensesForDateRange(DateTime start, DateTime end,
      {String? accountId}) {
    return getExpensesForDateRange(start, end, accountId: accountId)
        .fold(0, (sum, expense) => sum + expense.amount);
  }

  void addAll(List<Expense> expenses) {
    // Add the expenses to your existing list
    this.expenses.addAll(expenses);
    notifyListeners();
  }
}
