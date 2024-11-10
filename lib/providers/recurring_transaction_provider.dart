import 'package:flutter/foundation.dart';
import 'package:spendulum/models/recurring_transaction.dart';
import 'package:spendulum/db/database_helper.dart';
import 'package:spendulum/db/tables/recurring_transactions_table.dart';
import 'package:spendulum/providers/expense_provider.dart';
import 'package:spendulum/providers/income_provider.dart';
import 'package:spendulum/ui/widgets/logger.dart';
import 'package:flutter/material.dart';

class RecurringTransactionProvider with ChangeNotifier {
  List<RecurringTransaction> _recurringTransactions = [];
  final ExpenseProvider _expenseProvider;
  final IncomeProvider _incomeProvider;

  RecurringTransactionProvider(this._expenseProvider, this._incomeProvider);

  List<RecurringTransaction> get recurringTransactions =>
      _recurringTransactions;

  Future<void> addRecurringTransaction(RecurringTransaction transaction) async {
    try {
      await DatabaseHelper.instance.insert(
        RecurringTransactionsTable.tableName,
        {
          ...transaction.toJson(),
          RecurringTransactionsTable.columnLastProcessed:
              DateTime.now().toIso8601String(),
        },
      );

      _recurringTransactions.add(transaction);
      notifyListeners();
      AppLogger.info('Added recurring transaction: ${transaction.id}');
    } catch (e) {
      AppLogger.error('Error adding recurring transaction', error: e);
      rethrow;
    }
  }

  Future<void> updateRecurringTransaction(
      RecurringTransaction transaction) async {
    try {
      await DatabaseHelper.instance.update(
        RecurringTransactionsTable.tableName,
        {
          ...transaction.toJson(),
        },
        RecurringTransactionsTable.columnId,
        transaction.id,
      );

      final index =
          _recurringTransactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _recurringTransactions[index] = transaction;
        notifyListeners();
      }
      AppLogger.info('Updated recurring transaction: ${transaction.id}');
    } catch (e) {
      AppLogger.error('Error updating recurring transaction', error: e);
      rethrow;
    }
  }

  Future<void> deleteRecurringTransaction(String id) async {
    try {
      await DatabaseHelper.instance.delete(
        RecurringTransactionsTable.tableName,
        RecurringTransactionsTable.columnId,
        id,
      );

      _recurringTransactions.removeWhere((t) => t.id == id);
      notifyListeners();
      AppLogger.info('Deleted recurring transaction: $id');
    } catch (e) {
      AppLogger.error('Error deleting recurring transaction', error: e);
      rethrow;
    }
  }

  Future<void> loadTransactions() async {
    try {
      final transactions = await DatabaseHelper.instance
          .queryAllRows(RecurringTransactionsTable.tableName);

      _recurringTransactions = transactions
          .map((map) => RecurringTransaction.fromJson(map))
          .toList();
      notifyListeners();
      AppLogger.info(
          'Loaded ${_recurringTransactions.length} recurring transactions');
    } catch (e) {
      AppLogger.error('Error loading recurring transactions', error: e);
      rethrow;
    }
  }

  Future<void> processRecurringTransactions() async {
    final now = DateTime.now();
    AppLogger.info(
        'Processing recurring transactions at: ${now.toIso8601String()}');

    for (var transaction in _recurringTransactions) {
      try {
        if (!await _shouldProcessTransaction(transaction, now)) continue;

        await _createTransaction(transaction);

        // Update last processed time
        await DatabaseHelper.instance.update(
          RecurringTransactionsTable.tableName,
          {
            RecurringTransactionsTable.columnLastProcessed:
                now.toIso8601String()
          },
          RecurringTransactionsTable.columnId,
          transaction.id,
        );
      } catch (e) {
        AppLogger.error(
            'Error processing recurring transaction: ${transaction.id}',
            error: e);
      }
    }
  }

  Future<bool> _shouldProcessTransaction(
      RecurringTransaction transaction, DateTime now) async {
    if (!transaction.isActive) return false;
    if (transaction.endDate != null && transaction.endDate!.isBefore(now))
      return false;

    final lastProcessed = await _getLastProcessedDate(transaction);
    if (lastProcessed == null) return true;

    switch (transaction.frequency) {
      case RecurringFrequency.daily:
        return now.difference(lastProcessed).inDays >= 1;
      case RecurringFrequency.weekly:
        return now.difference(lastProcessed).inDays >= 7;
      case RecurringFrequency.monthly:
        return (now.year - lastProcessed.year) * 12 +
                now.month -
                lastProcessed.month >=
            1;
      case RecurringFrequency.yearly:
        return now.difference(lastProcessed).inDays >= 365;
      case RecurringFrequency.custom:
        return transaction.customDays != null &&
            now.difference(lastProcessed).inDays >= transaction.customDays!;
      default:
        return false;
    }
  }

  Future<DateTime?> _getLastProcessedDate(
      RecurringTransaction transaction) async {
    try {
      final results = await DatabaseHelper.instance.queryRows(
        RecurringTransactionsTable.tableName,
        where: '${RecurringTransactionsTable.columnId} = ?',
        whereArgs: [transaction.id],
      );

      if (results.isEmpty) return null;

      final lastProcessedStr =
          results.first[RecurringTransactionsTable.columnLastProcessed];

      return lastProcessedStr != null ? DateTime.parse(lastProcessedStr) : null;
    } catch (e) {
      AppLogger.error('Error getting last processed date', error: e);
      return null;
    }
  }

  Future<void> _createTransaction(RecurringTransaction transaction) async {
    if (transaction.isExpense) {
      await _expenseProvider.addExpense(
        transaction.categoryOrSource,
        transaction.amount,
        DateTime.now(),
        transaction.description,
        transaction.accountId,
      );
    } else {
      await _incomeProvider.addIncome(
        transaction.categoryOrSource,
        transaction.amount,
        DateTime.now(),
        transaction.description,
        transaction.accountId,
      );
    }
    AppLogger.info(
        'Created ${transaction.isExpense ? "expense" : "income"} from recurring transaction: ${transaction.id}');
  }
}
