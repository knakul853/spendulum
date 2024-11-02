import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:spendulum/models/budget.dart';
import 'package:spendulum/services/database/database_helper.dart';
import 'package:spendulum/ui/widgets/logger.dart';
import 'package:spendulum/services/database/tables/budget_table.dart';

class BudgetProvider with ChangeNotifier {
  List<Budget> _budgets = [];

  List<Budget> get budgets => _budgets;

  /// Loads all budgets from the database.
  ///
  /// This method queries all rows from the [BudgetsTable] and maps the results
  /// to a list of [Budget] objects. It then notifies all listeners of changes.
  ///
  /// If an error occurs during the database query, it is logged with an error
  /// level.
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
                categoryIds:
                    (map[BudgetsTable.columnCategoryId] as String).split(","),
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

  /// Adds a new budget to the database and the list of budgets.
  ///
  /// This method creates a new [Budget] object with the given parameters and
  /// adds it to the database using [_addBudgetToDatabase]. It then adds the new
  /// budget to the list of budgets and notifies all listeners of changes.
  ///
  /// If an error occurs during the database query, it is logged with an error
  /// level.
  Future<void> addBudget({
    required String name,
    required String accountId,
    List<String> categoryIds = const [],
    required double amount,
    required Period period,
  }) async {
    AppLogger.info('Adding new budget: $name');
    try {
      final newBudget = Budget(
        id: const Uuid().v4(),
        name: name,
        accountId: accountId,
        categoryIds: categoryIds,
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

  /// Adds the given [budget] to the database.
  ///
  /// This method inserts the budget's details into the [BudgetsTable].
  /// It logs the action before and after the insertion to track the
  /// addition of the budget to the database.
  ///
  /// The budget details include the ID, name, account ID, category ID,
  /// amount, period, start date, end date, and spent amount.
  ///
  /// The dates are stored as ISO 8601 strings.
  Future<void> _addBudgetToDatabase(Budget budget) async {
    AppLogger.info('Adding budget to the database: ${budget.name}');
    await DatabaseHelper.instance.insert(BudgetsTable.tableName, {
      BudgetsTable.columnId: budget.id,
      BudgetsTable.columnName: budget.name,
      BudgetsTable.columnAccountId: budget.accountId,
      BudgetsTable.columnCategoryId: budget.categoryIds
          .join(','), //Storing multiple category ids as comma separated.
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

  Future<void> updateBudget(
      {required String id,
      required String name,
      required String accountId,
      List<String> categoryIds = const [],
      required double amount,
      required Period period,
      required DateTime startDate,
      required DateTime? endDate,
      required bool rollover,
      required String notes}) async {
    AppLogger.info('Updating budget with ID: $id');
    try {
      final updatedBudget = Budget(
        id: id,
        name: name,
        accountId: accountId,
        categoryIds: categoryIds,
        amount: amount,
        period: period,
        startDate: startDate,
        endDate: endDate,
        rollover: rollover,
        notes: notes,
        updatedAt: DateTime.now(),
      );

      await DatabaseHelper.instance.update(
        BudgetsTable.tableName,
        {
          BudgetsTable.columnName: updatedBudget.name,
          BudgetsTable.columnAccountId: updatedBudget.accountId,
          BudgetsTable.columnCategoryId: updatedBudget.categoryIds.join(','),
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
        updatedBudget.status = _budgets[index].status;
        updatedBudget.spent = _budgets[index].spent;
        updatedBudget.createdAt = _budgets[index].createdAt;
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

  Future<List<Budget>> getBudgetsByCategory(String categoryId) async {
    return _budgets
        .where((budget) => budget.categoryIds.contains(categoryId))
        .toList();
  }

  Future<List<Budget>> getActiveBudgets() async {
    return _budgets
        .where((budget) => budget.status == BudgetStatus.active)
        .toList();
  }

  Future<List<Budget>> getExceededBudgets() async {
    return _budgets
        .where((budget) => budget.status == BudgetStatus.exceeded)
        .toList();
  }

  Future<void> pauseBudget(String id) async {
    AppLogger.info('Pausing budget with ID: $id');
    try {
      final budget = getBudgetById(id);
      if (budget != null) {
        budget.status = BudgetStatus.paused;
        budget.updatedAt = DateTime.now();
        await _updateBudgetInDatabase(budget);
        notifyListeners();
        AppLogger.info('Budget paused successfully: $id');
      }
    } catch (e) {
      AppLogger.error('Error pausing budget with ID: $id', error: e);
    }
  }

  Future<void> resumeBudget(String id) async {
    AppLogger.info('Resuming budget with ID: $id');
    try {
      final budget = getBudgetById(id);
      if (budget != null) {
        budget.status = BudgetStatus.active;
        budget.updatedAt = DateTime.now();
        await _updateBudgetInDatabase(budget);
        notifyListeners();
        AppLogger.info('Budget resumed successfully: $id');
      }
    } catch (e) {
      AppLogger.error('Error resuming budget with ID: $id', error: e);
    }
  }

  double getTotalBudgetedAmount() {
    return _budgets
        .where((budget) => budget.status == BudgetStatus.active)
        .fold(0.0, (sum, budget) => sum + budget.amount);
  }

  double getTotalSpentAmount() {
    return _budgets
        .where((budget) => budget.status == BudgetStatus.active)
        .fold(0.0, (sum, budget) => sum + budget.spent);
  }
}
