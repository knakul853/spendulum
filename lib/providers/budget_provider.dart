import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:spendulum/models/budget.dart';
import 'package:spendulum/services/database/database_helper.dart';
import 'package:spendulum/ui/widgets/logger.dart';
import 'package:spendulum/services/database/tables/budget_table.dart';

class BudgetProvider with ChangeNotifier {
  List<Budget> _budgets = [];

  List<Budget> get budgets => _budgets;

  Future<void> loadBudgets() async {
    AppLogger.info('Loading budgets from the database');
    try {
      final budgetMaps =
          await DatabaseHelper.instance.queryAllRows(BudgetsTable.tableName);

      _budgets = budgetMaps
          .map((map) => Budget(
                id: map[BudgetsTable.columnId] as String,
                name: map[BudgetsTable.columnName] as String,
                accountId: map[BudgetsTable.columnAccountId] as String,
                categoryId: map[BudgetsTable.columnCategoryId] as String?,
                amount: map[BudgetsTable.columnAmount] as double,
                period: Period.values[map[BudgetsTable.columnPeriod] as int],
                startDate:
                    DateTime.parse(map[BudgetsTable.columnStartDate] as String),
                endDate:
                    DateTime.parse(map[BudgetsTable.columnEndDate] as String),
                spent: map[BudgetsTable.columnSpent] as double,
              ))
          .toList();

      AppLogger.info('Loaded ${_budgets.length} budgets successfully');
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error loading budgets from the database', error: e);
    }
  }

  Future<void> addBudget({
    required String name,
    required String accountId,
    String? categoryId,
    required double amount,
    required Period period,
  }) async {
    AppLogger.info('Adding new budget: $name');
    try {
      final newBudget = Budget(
        id: const Uuid().v4(),
        name: name,
        accountId: accountId,
        categoryId: categoryId,
        amount: amount,
        period: period,
        startDate: DateTime.now(),
      );

      await _addBudgetToDatabase(newBudget);
      _budgets.add(newBudget);
      notifyListeners();
      AppLogger.info('Budget added successfully: ${newBudget.id}');
    } catch (e) {
      AppLogger.error('Error adding budget', error: e);
    }
  }

  Future<void> _addBudgetToDatabase(Budget budget) async {
    AppLogger.info('Adding budget to the database: ${budget.name}');
    await DatabaseHelper.instance.insert(BudgetsTable.tableName, {
      BudgetsTable.columnId: budget.id,
      BudgetsTable.columnName: budget.name,
      BudgetsTable.columnAccountId: budget.accountId,
      BudgetsTable.columnCategoryId: budget.categoryId,
      BudgetsTable.columnAmount: budget.amount,
      BudgetsTable.columnPeriod: budget.period.index,
      BudgetsTable.columnStartDate: budget.startDate.toIso8601String(),
      BudgetsTable.columnEndDate: budget.endDate.toIso8601String(),
      BudgetsTable.columnSpent: budget.spent,
    });
    AppLogger.info('Budget added to the database: ${budget.id}');
  }

  Future<void> removeBudget(String id) async {
    AppLogger.info('Removing budget with ID: $id');
    try {
      await DatabaseHelper.instance.delete(
        BudgetsTable.tableName,
        BudgetsTable.columnId,
        id,
      );

      _budgets.removeWhere((budget) => budget.id == id);
      notifyListeners();
      AppLogger.info('Budget removed successfully: $id');
    } catch (e) {
      AppLogger.error('Error removing budget with ID: $id', error: e);
    }
  }

  Future<void> updateBudget({
    required String id,
    required String name,
    required String accountId,
    String? categoryId,
    required double amount,
    required Period period,
  }) async {
    AppLogger.info('Updating budget with ID: $id');
    try {
      final updatedBudget = Budget(
        id: id,
        name: name,
        accountId: accountId,
        categoryId: categoryId,
        amount: amount,
        period: period,
        startDate: DateTime.now(),
      );

      await DatabaseHelper.instance.update(
        BudgetsTable.tableName,
        {
          BudgetsTable.columnName: updatedBudget.name,
          BudgetsTable.columnAccountId: updatedBudget.accountId,
          BudgetsTable.columnCategoryId: updatedBudget.categoryId,
          BudgetsTable.columnAmount: updatedBudget.amount,
          BudgetsTable.columnPeriod: updatedBudget.period.index,
          BudgetsTable.columnStartDate:
              updatedBudget.startDate.toIso8601String(),
          BudgetsTable.columnEndDate: updatedBudget.endDate.toIso8601String(),
          BudgetsTable.columnSpent: updatedBudget.spent,
        },
        BudgetsTable.columnId,
        id,
      );

      final index = _budgets.indexWhere((budget) => budget.id == id);
      if (index != -1) {
        _budgets[index] = updatedBudget;
        notifyListeners();
      }
      AppLogger.info('Budget updated successfully: $id');
    } catch (e) {
      AppLogger.error('Error updating budget with ID: $id', error: e);
    }
  }

  Budget? getBudgetById(String id) {
    AppLogger.info('Retrieving budget with ID: $id');
    try {
      return _budgets.firstWhere((budget) => budget.id == id);
    } catch (e) {
      AppLogger.warn('Budget not found with ID: $id');
      return null;
    }
  }

  Future<void> updateBudgetSpent(String id, double amount) async {
    AppLogger.info('Updating spent amount for budget with ID: $id');
    try {
      final budget = getBudgetById(id);
      if (budget != null) {
        budget.addExpense(amount);
        await DatabaseHelper.instance.update(
          BudgetsTable.tableName,
          {BudgetsTable.columnSpent: budget.spent},
          BudgetsTable.columnId,
          id,
        );
        notifyListeners();
        AppLogger.info('Budget spent amount updated successfully: $id');
      } else {
        AppLogger.warn('Budget not found for updating spent amount: $id');
      }
    } catch (e) {
      AppLogger.error('Error updating budget spent amount with ID: $id',
          error: e);
    }
  }

  void checkAndResetBudgets() {
    AppLogger.info('Checking and resetting budgets');
    final now = DateTime.now();
    for (final budget in _budgets) {
      if (now.isAfter(budget.endDate)) {
        budget.resetBudget();
        _updateBudgetInDatabase(budget);
      }
    }
    notifyListeners();
    AppLogger.info('Budgets checked and reset if necessary');
  }

  Future<void> _updateBudgetInDatabase(Budget budget) async {
    AppLogger.info('Updating budget in database: ${budget.id}');
    await DatabaseHelper.instance.update(
      BudgetsTable.tableName,
      {
        BudgetsTable.columnStartDate: budget.startDate.toIso8601String(),
        BudgetsTable.columnEndDate: budget.endDate.toIso8601String(),
        BudgetsTable.columnSpent: budget.spent,
      },
      BudgetsTable.columnId,
      budget.id,
    );
    AppLogger.info('Budget updated in database: ${budget.id}');
  }
}
