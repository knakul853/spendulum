import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:spendulum/models/account.dart';
import 'package:spendulum/db/database_helper.dart';
import 'package:spendulum/db/tables/accounts_table.dart';
import 'package:spendulum/ui/widgets/logger.dart';
import 'package:spendulum/db/tables/expense_table.dart';

// AccountProvider class manages the accounts in the application.
// It handles loading, adding, updating, and selecting accounts,
// and notifies listeners of any changes to the account data.

class AccountProvider with ChangeNotifier {
  List<Account> _accounts = [];
  String? _selectedAccountId;

  List<Account> get accounts => _accounts;
  String? get selectedAccountId => _selectedAccountId;

  /// Loads all accounts from the database and updates the [_accounts] list.
  ///
  /// The selected account is set to the latest account (i.e., the account with the
  /// most recent creation date) if the list of accounts is not empty.
  ///
  /// Listeners are notified of the change after the accounts are loaded.
  ///
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
      } else {
        _selectedAccountId = null;
        AppLogger.info('No accounts found in database');
      }

      notifyListeners(); // Notify listeners of the change
    } catch (e) {
      AppLogger.error('Error loading accounts', error: e);
      _accounts = [];
      _selectedAccountId = null;
      notifyListeners();
    }
  }

  /// Adds a new account to the database and updates the local list.
  ///
  /// The [name], [accountNumber], [accountType], [balance], [color], and
  /// [currency] parameters specify the new account to be added.
  ///
  /// If the account is added successfully, the local list of accounts is updated
  /// and listeners are notified of the change. If the account already exists with
  /// the given [id], an error is logged. If the addition fails, an error is
  /// logged.
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
  /// Updates an existing account in the database and local list.
  ///
  /// The [id] parameter is the unique ID of the account to be updated.
  ///
  /// The [name], [accountNumber], [accountType], [balance], [color], and
  /// [currency] parameters specify the new values for the account.
  ///
  /// If the update is successful, the local list of accounts is updated and
  /// listeners are notified of the change. If the update fails, an error is
  /// logged.
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

  /// Deletes an account and its associated expenses from the database and local list.
  ///
  /// The [id] parameter is the unique identifier of the account to be deleted.
  /// The [accountNumber] parameter is used to verify the account before deletion.
  ///
  /// If the account with the provided [id] and [accountNumber] exists, it is removed
  /// from the database and the local list of accounts. Associated expenses are also
  /// deleted. Listeners are notified of the change. If the account number does not
  /// match, a warning is logged and no deletion occurs.
  ///
  /// Logs an error if the deletion fails.
  Future<void> deleteAccount(String id, String accountNumber) async {
    final account = getAccountById(id);
    if (account != null && account.accountNumber == accountNumber) {
      AppLogger.info('Deleting account: $id');
      try {
        await DatabaseHelper.instance
            .delete(AccountsTable.tableName, AccountsTable.columnId, id);
        // Delete associated expenses
        await DatabaseHelper.instance
            .delete(ExpensesTable.tableName, ExpensesTable.columnAccountId, id);
        _accounts.removeWhere(
            (account) => account.id == id); // Remove from local list
        notifyListeners(); // Notify listeners of the change
        AppLogger.info('Account deleted successfully: $id');
      } catch (e) {
        AppLogger.error('Error deleting account', error: e);
      }
    } else {
      AppLogger.warn(
          'Account number does not match for deletion: $accountNumber');
    }
  }

  /// Selects an account by its unique ID and updates the selected account state.
  ///
  /// The [id] parameter is the unique identifier of the account to be selected.
  /// This method updates the [_selectedAccountId] to the given [id], logs the
  /// selection, and notifies listeners about the change.
  void selectAccount(String id) {
    _selectedAccountId = id; // Set selected account ID
    AppLogger.info('Selected account: $id');
    notifyListeners(); // Notify listeners of the change
  }

  /// Retrieves the currently selected account.
  ///
  /// If there is no selected account or the accounts list is empty, this
  /// method returns null and logs a warning. If the selected account is not
  /// found in the accounts list, this method resets the selection and returns
  /// null. Otherwise, it returns the selected account.
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

  /// Updates the balance of an account by a specified amount.
  ///
  /// The [id] parameter is the unique ID of the account to be updated.
  ///
  /// The [amount] parameter is the amount to be added to the account balance.
  /// A positive amount increases the balance, a negative amount decreases it.
  ///
  /// If the account is found in the local list, this method updates the balance
  /// and notifies listeners of the change. If the account is not found, this
  /// method logs a warning and does not update the balance.
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

  /// Retrieves an account by its unique ID.
  ///
  /// The [id] parameter is the unique identifier of the account to be retrieved.
  ///
  /// Returns the [Account] object if found, otherwise returns null.
  /// Logs a warning if the account is not found.
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

  /// Retrieves the latest account based on the updatedAt timestamp.
  ///
  /// Returns the [Account] object of the latest account, which is the account
  /// with the most recent updatedAt timestamp. If the accounts list is empty,
  /// this method returns null and logs a warning.
  Account getLatestAccount() {
    return _accounts.reduce((a, b) => a.updatedAt.isAfter(b.updatedAt) ? a : b);
  }

  Account getOldestAccount() {
    return _accounts
        .reduce((a, b) => a.updatedAt.isBefore(b.updatedAt) ? a : b);
  }
}
