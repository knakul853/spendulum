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
                categories:
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
        categories: categoryIds,
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
      BudgetsTable.columnCategoryId: budget.categories
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

  /// Updates an existing budget in the database and the list of budgets.
  ///
  /// This method updates the budget identified by the given [id] with new
  /// details provided in the parameters. It constructs a new [Budget] object
  /// with the updated information and performs a database update operation
  /// using [DatabaseHelper]. The list of budgets is also updated accordingly,
  /// and all listeners are notified of the changes.
  ///
  /// The budget details include the ID, name, account ID, category IDs,
  /// amount, period, start date, end date, rollover status, and notes.
  ///
  /// If an error occurs during the update process, it is logged with an error
  /// level.
  Future<void> updateBudget(
      {required String id,
      required String name,
      required String accountId,
      List<String> categories = const [],
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
        categories: categories,
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
          BudgetsTable.columnCategoryId: updatedBudget.categories.join(','),
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

  /// Retrieves a [Budget] by its ID.
  ///
  /// If the budget is not found, [null] is returned and a warning is logged.
  ///
  /// [id] is the ID of the [Budget] to retrieve.
  Budget? getBudgetById(String id) {
    AppLogger.info('Retrieving budget with ID: $id');
    try {
      return _budgets.firstWhere((budget) => budget.id == id);
    } catch (e) {
      AppLogger.warn('Budget not found with ID: $id');
      return null;
    }
  }

  /// Updates the spent amount for a budget identified by the given [id].
  ///
  /// This method retrieves the budget by its ID and adds the specified [amount]
  /// to the budget's spent amount. It then updates the database with the new
  /// spent amount and notifies listeners of the change. If the budget is not
  /// found, a warning is logged. In case of an error during the update, it is
  /// logged with an error level.
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

  /// Checks all budgets and resets them if their end date has been reached.
  ///
  /// This method iterates over all budgets and checks if the current date is
  /// after the budget's end date. If so, it resets the budget by calling
  /// [Budget.resetBudget] and updates the database with the new values.
  /// Finally, it notifies all listeners of the change.
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

  /// Updates a budget in the database.
  ///
  /// This method updates the budget with the given [id] in the database
  /// with the new values from the [budget] object. It logs the action
  /// before and after the update to track changes to the database.
  ///
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

  /// Returns a list of budgets that match the given [categoryId].
  ///
  /// This method filters the list of budgets to only include those that
  /// contain the given [categoryId]. It then returns the filtered list.
  ///
  /// The budgets are filtered in memory and do not result in a database query.
  ///
  Future<List<Budget>> getBudgetsByCategory(String categoryId) async {
    return _budgets
        .where((budget) => budget.categories.contains(categoryId))
        .toList();
  }

  /// Returns a list of budgets that are currently active.
  ///
  /// This method filters the list of budgets to only include those that
  /// have a status of [BudgetStatus.active]. It then returns the filtered
  /// list.
  ///
  /// The budgets are filtered in memory and do not result in a database query.
  Future<List<Budget>> getActiveBudgets() async {
    return _budgets
        .where((budget) => budget.status == BudgetStatus.active)
        .toList();
  }

  /// Returns a list of budgets that have exceeded their target amount.
  ///
  /// This method filters the list of budgets to only include those that
  /// have a status of [BudgetStatus.exceeded]. It then returns the filtered
  /// list.
  ///
  /// The budgets are filtered in memory and do not result in a database query.
  Future<List<Budget>> getExceededBudgets() async {
    return _budgets
        .where((budget) => budget.status == BudgetStatus.exceeded)
        .toList();
  }

  /// Pauses the budget with the given [id].
  ///
  /// This method sets the budget's status to [BudgetStatus.paused] and
  /// updates the database with the new status. It then notifies all listeners
  /// of changes.
  ///
  /// If an error occurs during the update, it is logged with an error level.
  ///
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

  /// Resumes the budget with the given [id].
  ///
  /// This method sets the budget's status to [BudgetStatus.active] and
  /// updates the database with the new status. It then notifies all listeners
  /// of changes.
  ///
  /// If an error occurs during the update, it is logged with an error level.
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

  /// Returns the total amount of active budgets.
  ///
  /// This method calculates the total budgeted amount by summing up the
  /// amounts of all active budgets. It only includes budgets with a status
  /// of [BudgetStatus.active].
  ///
  /// The total budgeted amount is the total amount that has been allocated
  /// for all budgets. It does not include the amount that has already been
  /// spent.
  double getTotalBudgetedAmount() {
    return _budgets
        .where((budget) => budget.status == BudgetStatus.active)
        .fold(0.0, (sum, budget) => sum + budget.amount);
  }

  /// Returns the total spent amount for active budgets.
  ///
  /// This method calculates the total spent amount by summing up the
  /// spent amounts of all active budgets. It only includes budgets with
  /// a status of [BudgetStatus.active].
  ///
  /// The total spent amount is the total amount that has been spent
  /// across all active budgets.
  double getTotalSpentAmount() {
    return _budgets
        .where((budget) => budget.status == BudgetStatus.active)
        .fold(0.0, (sum, budget) => sum + budget.spent);
  }
}
