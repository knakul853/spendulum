import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:spendulum/models/account.dart';
import 'package:spendulum/services/database/database_helper.dart';
import 'package:spendulum/services/database/tables/accounts_table.dart';
import 'package:spendulum/ui/widgets/logger.dart';

class AccountProvider with ChangeNotifier {
  List<Account> _accounts = [];
  String? _selectedAccountId;

  List<Account> get accounts => _accounts;
  String? get selectedAccountId => _selectedAccountId;

  Future<void> loadAccounts() async {
    AppLogger.info('Loading accounts');
    try {
      final accountMaps =
          await DatabaseHelper.instance.queryAllRows(AccountsTable.tableName);
      _accounts = accountMaps
          .map((map) => Account(
                id: map[AccountsTable.columnId] as String,
                name: map[AccountsTable.columnName] as String,
                accountNumber: map[AccountsTable.columnAccountNumber] as String,
                accountType: map[AccountsTable.columnAccountType] as String,
                balance: map[AccountsTable.columnBalance] as double,
                color: Color(map[AccountsTable.columnColor] as int),
                currency: map[AccountsTable.columnCurrency] as String,
                createdAt: DateTime.fromMillisecondsSinceEpoch(
                    map[AccountsTable.columnCreatedAt] as int),
                updatedAt: DateTime.fromMillisecondsSinceEpoch(
                    map[AccountsTable.columnUpdatedAt] as int),
              ))
          .toList();
      AppLogger.info('Loaded ${_accounts.length} accounts');

      // Select the latest account as the selected account
      if (_accounts.isNotEmpty) {
        _selectedAccountId = getLatestAccount().id;
      }

      notifyListeners();
    } catch (e) {
      AppLogger.error('Error loading accounts', error: e);
    }
  }

  Future<void> addAccount(String name, String accountNumber, String accountType,
      double balance, Color color, String currency) async {
    AppLogger.info('Adding new account: $name');

    try {
      final now = DateTime.now();
      final newAccount = Account(
        id: const Uuid().v4(),
        name: name,
        accountNumber: accountNumber,
        accountType: accountType,
        balance: balance,
        color: color,
        currency: currency,
        createdAt: now,
        updatedAt: now,
      );
      await DatabaseHelper.instance.insert(AccountsTable.tableName, {
        AccountsTable.columnId: newAccount.id,
        AccountsTable.columnName: newAccount.name,
        AccountsTable.columnAccountNumber: newAccount.accountNumber,
        AccountsTable.columnAccountType: newAccount.accountType,
        AccountsTable.columnBalance: newAccount.balance,
        AccountsTable.columnColor: newAccount.color.value,
        AccountsTable.columnCurrency: newAccount.currency,
        AccountsTable.columnCreatedAt:
            newAccount.createdAt.millisecondsSinceEpoch,
        AccountsTable.columnUpdatedAt:
            newAccount.updatedAt.millisecondsSinceEpoch,
      });
      _accounts.add(newAccount);
      _selectedAccountId = newAccount.id;
      notifyListeners();
      AppLogger.info('Account added successfully: ${newAccount.id}');
    } catch (e) {
      AppLogger.error('Error adding account', error: e);
    }
  }

  Future<void> updateAccount(String id, String name, String accountNumber,
      String accountType, double balance, Color color, String currency) async {
    AppLogger.info('Updating account: $name');

    try {
      final now = DateTime.now();
      final updatedAccount = Account(
        id: id,
        name: name,
        accountNumber: accountNumber,
        accountType: accountType,
        balance: balance,
        color: color,
        currency: currency,
        createdAt: getAccountById(id)?.createdAt ?? now, // Preserve createdAt
        updatedAt: now,
      );
      await DatabaseHelper.instance.update(
        AccountsTable.tableName,
        {
          AccountsTable.columnName: updatedAccount.name,
          AccountsTable.columnAccountNumber: updatedAccount.accountNumber,
          AccountsTable.columnAccountType: updatedAccount.accountType,
          AccountsTable.columnBalance: updatedAccount.balance,
          AccountsTable.columnColor: updatedAccount.color.value,
          AccountsTable.columnCurrency: updatedAccount.currency,
          AccountsTable.columnUpdatedAt:
              updatedAccount.updatedAt.millisecondsSinceEpoch,
        },
        AccountsTable.columnId,
        id,
      );
      final index = _accounts.indexWhere((account) => account.id == id);
      if (index != -1) {
        _accounts[index] = updatedAccount;
        notifyListeners();
      }
      AppLogger.info('Account updated successfully: $id');
    } catch (e) {
      AppLogger.error('Error updating account', error: e);
    }
  }

  void selectAccount(String id) {
    _selectedAccountId = id;
    notifyListeners();
  }

  Account? getSelectedAccount() {
    if (_selectedAccountId == null || _accounts.isEmpty) {
      return null;
    }
    try {
      return _accounts
          .firstWhere((account) => account.id == _selectedAccountId);
    } catch (e) {
      // If the selected account is not found, reset the selection
      _selectedAccountId = null;
      return null;
    }
  }

  void updateAccountBalance(String id, double amount) {
    final accountIndex = _accounts.indexWhere((account) => account.id == id);
    if (accountIndex != -1) {
      _accounts[accountIndex].balance += amount;
      notifyListeners();
    }
  }

  Account? getAccountById(String id) {
    try {
      return accounts.firstWhere((account) => account.id == id);
    } catch (e) {
      return null;
    }
  }

  String getCurrencyCode(String id) {
    final account = getAccountById(id);
    return account?.currency ??
        'USD'; // Return the currency code of the account
  }

  Account getLatestAccount() {
    return _accounts.reduce((a, b) => a.updatedAt.isAfter(b.updatedAt) ? a : b);
  }
}
