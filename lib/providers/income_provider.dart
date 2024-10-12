import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:spendulum/models/income.dart';
import 'package:spendulum/providers/account_provider.dart';
import 'package:spendulum/services/database/database_helper.dart';
import 'package:spendulum/ui/widgets/logger.dart';
import 'package:spendulum/services/database/tables/incomes_table.dart';

class IncomeProvider with ChangeNotifier {
  final List<Income> _incomes = [];
  final AccountProvider _accountProvider;

  IncomeProvider(this._accountProvider);

  List<Income> get incomes => _incomes;

  Future<void> loadIncomes(String accountId, DateTime month) async {
    AppLogger.info(
        'IncomeProvider: Loading incomes for account $accountId and month $month');
    try {
      final incomeMaps =
          await DatabaseHelper.instance.queryAllRows(IncomesTable.tableName);
      _incomes.clear();
      _incomes.addAll(incomeMaps.where((map) {
        final incomeDate =
            DateTime.parse(map[IncomesTable.columnDate] as String);
        return map[IncomesTable.columnAccountId] == accountId &&
            incomeDate.year == month.year &&
            incomeDate.month == month.month;
      }).map((map) => Income(
            id: map[IncomesTable.columnId] as String,
            source: map[IncomesTable.columnSource] as String,
            amount: map[IncomesTable.columnAmount] as double,
            date: DateTime.parse(map[IncomesTable.columnDate] as String),
            description: map[IncomesTable.columnDescription] as String,
            accountId: map[IncomesTable.columnAccountId] as String,
          )));
      AppLogger.info('IncomeProvider: Loaded ${_incomes.length} incomes');
      notifyListeners();
    } catch (e) {
      AppLogger.error('IncomeProvider: Error loading incomes', error: e);
    }
  }

  Future<void> addIncome(String source, double amount, DateTime date,
      String description, String accountId) async {
    AppLogger.info('IncomeProvider: Adding new income: $source, $amount');
    try {
      final newIncome = Income(
        id: const Uuid().v4(),
        source: source,
        amount: amount,
        date: date,
        description: description,
        accountId: accountId,
      );

      await DatabaseHelper.instance.insert(IncomesTable.tableName, {
        IncomesTable.columnId: newIncome.id,
        IncomesTable.columnSource: newIncome.source,
        IncomesTable.columnAmount: newIncome.amount,
        IncomesTable.columnDate: newIncome.date.toIso8601String(),
        IncomesTable.columnDescription: newIncome.description,
        IncomesTable.columnAccountId: newIncome.accountId,
      });

      _incomes.add(newIncome);
      _accountProvider.updateAccountBalance(accountId, amount);
      notifyListeners();
      AppLogger.info(
          'IncomeProvider: Income added successfully: ${newIncome.id}');
    } catch (e) {
      AppLogger.error('IncomeProvider: Error adding income', error: e);
    }
  }

  List<Income> getIncomesForMonth(DateTime month, {String? accountId}) {
    AppLogger.info(
        'IncomeProvider: Retrieving incomes for month: ${month.toIso8601String()}');
    return _incomes
        .where((income) =>
            income.date.year == month.year &&
            income.date.month == month.month &&
            (accountId == null || income.accountId == accountId))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  double getTotalIncomeForMonth(DateTime month, {String? accountId}) {
    AppLogger.info(
        'IncomeProvider: Calculating total income for month: ${month.toIso8601String()}');
    return getIncomesForMonth(month, accountId: accountId)
        .fold(0, (sum, income) => sum + income.amount);
  }

  void addAll(List<Income> newIncomes) {
    incomes.addAll(newIncomes);
  }
}
