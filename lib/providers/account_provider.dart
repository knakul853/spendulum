import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:budget_buddy/models/account.dart';

class AccountProvider with ChangeNotifier {
  final List<Account> _accounts = [];
  String? _selectedAccountId;

  List<Account> get accounts => _accounts;
  String? get selectedAccountId => _selectedAccountId;

  void addAccount(String name, String accountNumber, String accountType,
      double balance, Color color, String currency) {
    final newAccount = Account(
        id: const Uuid().v4(),
        name: name,
        accountNumber: accountNumber,
        accountType: accountType,
        balance: balance,
        color: color,
        currency: currency);
    _accounts.add(newAccount);
    if (_accounts.length == 1) {
      _selectedAccountId = newAccount.id;
    }
    notifyListeners();
  }

  void updateAccount(String id, String name, String accountNumber,
      String accountType, double balance, Color color, String currency) {
    final index = _accounts.indexWhere((account) => account.id == id);
    if (index != -1) {
      _accounts[index] = Account(
          id: id,
          name: name,
          accountNumber: accountNumber,
          accountType: accountType,
          balance: balance,
          color: color,
          currency: currency);
      notifyListeners();
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
}
