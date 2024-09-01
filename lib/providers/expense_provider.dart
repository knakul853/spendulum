import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:spendulum/models/expense.dart';
import 'package:spendulum/providers/account_provider.dart';

class ExpenseProvider with ChangeNotifier {
  final List<Expense> _expenses = [];
  double _monthlyBudget = 0.0;
  final AccountProvider _accountProvider;

  ExpenseProvider(this._accountProvider);

  List<Expense> get expenses => _expenses;
  double get monthlyBudget => _monthlyBudget;

  void addExpense(String category, double amount, DateTime date,
      String description, String accountId) {
    final newExpense = Expense(
      id: const Uuid().v4(),
      category: category,
      amount: amount,
      date: date,
      description: description,
      accountId: accountId,
    );

    _expenses.add(newExpense);
    _accountProvider.updateAccountBalance(accountId, -amount);
    notifyListeners();
  }

  double getTotalExpenses({String? accountId}) {
    if (accountId == null) {
      return _expenses.fold(0, (sum, expense) => sum + expense.amount);
    }
    return _expenses
        .where((expense) => expense.accountId == accountId)
        .fold(0, (sum, expense) => sum + expense.amount);
  }

  void addAll(List<Expense> expenses) {
    _expenses.addAll(expenses);
    notifyListeners();
  }

  double getCurrentMonthExpenses({String? accountId}) {
    final now = DateTime.now();
    return _expenses
        .where((expense) =>
            expense.date.year == now.year &&
            expense.date.month == now.month &&
            (accountId == null || expense.accountId == accountId))
        .fold(0, (sum, expense) => sum + expense.amount);
  }

  void setMonthlyBudget(double budget) {
    _monthlyBudget = budget;
    notifyListeners();
  }

  double getMonthlyBudget() {
    return _monthlyBudget;
  }

  double getRemainingBudget({String? accountId}) {
    return _monthlyBudget - getCurrentMonthExpenses(accountId: accountId);
  }

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

  List<Expense> getExpensesForMonth(DateTime month, {String? accountId}) {
    return _expenses
        .where((expense) =>
            expense.date.year == month.year &&
            expense.date.month == month.month &&
            (accountId == null || expense.accountId == accountId))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  double getTotalExpensesForMonth(DateTime month, {String? accountId}) {
    return getExpensesForMonth(month, accountId: accountId)
        .fold(0, (sum, expense) => sum + expense.amount);
  }

  List<Expense> get sortedExpenses {
    // Sort expenses by date in descending order
    _expenses.sort((a, b) => b.date.compareTo(a.date));
    return _expenses;
  }
}
