import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:spendulum/models/account.dart';
import 'package:spendulum/services/database/database_helper.dart';
import 'package:spendulum/services/database/tables/accounts_table.dart';
import 'package:spendulum/ui/widgets/logger.dart';

// AccountProvider class manages the accounts in the application.
// It handles loading, adding, updating, and selecting accounts,
// and notifies listeners of any changes to the account data.

class AccountProvider with ChangeNotifier {
  List<Account> _accounts = []; // List of accounts
  String? _selectedAccountId; // Currently selected account ID

  List<Account> get accounts => _accounts; // Getter for accounts
  String? get selectedAccountId =>
      _selectedAccountId; // Getter for selected account ID

  // Loads accounts from the database and updates the _accounts list
  Future<void> loadAccounts() async {
    AppLogger.info('Loading accounts from the database');
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
        _selectedAccountId = getOldestAccount().id;
        AppLogger.info('Selected latest account: ${_selectedAccountId}');
      }

      notifyListeners(); // Notify listeners of the change
    } catch (e) {
      AppLogger.error('Error loading accounts', error: e);
    }
  }

  // Adds a new account to the database and updates the local list
  Future<void> addAccount(String name, String accountNumber, String accountType,
      double balance, Color color, String currency) async {
    AppLogger.info('Adding new account: $name');

    try {
      final now = DateTime.now();
      final newAccount = Account(
        id: const Uuid().v4(), // Generate a unique ID
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
      _accounts.add(newAccount); // Add to local list
      _selectedAccountId = newAccount.id; // Set as selected
      notifyListeners(); // Notify listeners of the change
      AppLogger.info('Account added successfully: ${newAccount.id}');
    } catch (e) {
      AppLogger.error('Error adding account', error: e);
    }
  }

  // Updates an existing account in the database and local list
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
        _accounts[index] = updatedAccount; // Update local list
        notifyListeners(); // Notify listeners of the change
      }
      AppLogger.info('Account updated successfully: $id');
    } catch (e) {
      AppLogger.error('Error updating account', error: e);
    }
  }

  // Selects an account by ID
  void selectAccount(String id) {
    _selectedAccountId = id; // Set selected account ID
    AppLogger.info('Selected account: $id');
    notifyListeners(); // Notify listeners of the change
  }

  // Retrieves the currently selected account
  Account? getSelectedAccount() {
    if (_selectedAccountId == null || _accounts.isEmpty) {
      AppLogger.warn('No selected account or accounts are empty');
      return null;
    }
    try {
      return _accounts
          .firstWhere((account) => account.id == _selectedAccountId);
    } catch (e) {
      // If the selected account is not found, reset the selection
      AppLogger.warn('Selected account not found, resetting selection');
      _selectedAccountId = null;
      return null;
    }
  }

  // Updates the balance of an account by a specified amount
  void updateAccountBalance(String id, double amount) {
    final accountIndex = _accounts.indexWhere((account) => account.id == id);
    if (accountIndex != -1) {
      _accounts[accountIndex].balance += amount; // Update balance
      AppLogger.info(
          'Updated balance for account: $id, new balance: ${_accounts[accountIndex].balance}');
      notifyListeners(); // Notify listeners of the change
    } else {
      AppLogger.warn('Account not found for balance update: $id');
    }
  }

  // Retrieves an account by its ID
  Account? getAccountById(String id) {
    try {
      return accounts.firstWhere((account) => account.id == id);
    } catch (e) {
      AppLogger.warn('Account not found by ID: $id');
      return null;
    }
  }

  // Gets the currency code for a specific account
  String getCurrencyCode(String id) {
    final account = getAccountById(id);
    return account?.currency ??
        'USD'; // Return the currency code of the account
  }

  // Retrieves the latest account based on the updatedAt timestamp
  Account getLatestAccount() {
    return _accounts.reduce((a, b) => a.updatedAt.isAfter(b.updatedAt) ? a : b);
  }

  Account getOldestAccount() {
    return _accounts
        .reduce((a, b) => a.updatedAt.isBefore(b.updatedAt) ? a : b);
  }
}
