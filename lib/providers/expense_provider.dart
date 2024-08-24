import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:budget_buddy/models/expense.dart';

class ExpenseProvider with ChangeNotifier {
  final List<Expense> _expenses = [];
  double _monthlyBudget = 0.0;

  List<Expense> get expenses => _expenses;
  double get monthlyBudget => _monthlyBudget;

  // Method to add a new expense
  void addExpense(
      String category, double amount, DateTime date, String description) {
    final newExpense = Expense(
      id: const Uuid().v4(), // Generate unique ID for each expense
      category: category,
      amount: amount,
      date: date,
      description: description,
    );

    _expenses.add(newExpense);
    notifyListeners(); // Notify listeners about the change
    debugPrint(
        'Expense added: $newExpense'); // Log the addition of a new expense
  }

  // Method to get total expenses
  double getTotalExpenses() {
    return _expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  // Method to get total expenses for the current month
  double getCurrentMonthExpenses() {
    final now = DateTime.now();
    return _expenses
        .where((expense) =>
            expense.date.year == now.year && expense.date.month == now.month)
        .fold(0, (sum, expense) => sum + expense.amount);
  }

  // Method to set monthly budget
  void setMonthlyBudget(double budget) {
    _monthlyBudget = budget;
    notifyListeners();
    debugPrint('Monthly budget set to: $budget');
  }

  // Method to get monthly budget
  double getMonthlyBudget() {
    return _monthlyBudget;
  }

  // Method to get remaining budget for the current month
  double getRemainingBudget() {
    return _monthlyBudget - getCurrentMonthExpenses();
  }

  // Method to get expenses by category
  Map<String, double> getExpensesByCategory() {
    final categoryExpenses = <String, double>{};
    for (var expense in _expenses) {
      categoryExpenses[expense.category] =
          (categoryExpenses[expense.category] ?? 0) + expense.amount;
    }
    return categoryExpenses;
  }
}
