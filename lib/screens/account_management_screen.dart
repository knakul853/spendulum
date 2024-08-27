import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:budget_buddy/providers/account_provider.dart';
import 'package:budget_buddy/models/account.dart';

class AccountManagementScreen extends StatefulWidget {
  const AccountManagementScreen({Key? key}) : super(key: key);

  @override
  _AccountManagementScreenState createState() =>
      _AccountManagementScreenState();
}

class _AccountManagementScreenState extends State<AccountManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _accountNumber;
  late String _accountType;
  late double _balance;
  late Color _color;
  late String _currency;

  final List<String> _accountTypes = [
    'General',
    'Cash',
    'Current Account',
    'Credit Card',
    'Savings Account',
    'Bonus',
    'Insurance',
    'Investment',
    'Loan',
    'Mortgage',
    'Account with Overdraft',
    'Other'
  ];

  final List<String> _currencies = ['USD', 'EUR', 'GBP', 'JPY', 'INR', 'Other'];

  @override
  void initState() {
    super.initState();
    _color = Colors.blue;
    _accountType = _accountTypes[0];
    _currency = _currencies[0];
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final accountProvider =
          Provider.of<AccountProvider>(context, listen: false);
      accountProvider.addAccount(
          _name, _accountNumber, _accountType, _balance, _color, _currency);
      Navigator.of(context).pop(); // Close the add account dialog
      _showSuccessSnackBar();
    }
  }

  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Account successfully added'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Accounts'),
        elevation: 0,
      ),
      body: Consumer<AccountProvider>(
        builder: (context, accountProvider, child) {
          if (accountProvider.accounts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_balance_wallet,
                      size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No accounts found',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Add an account to get started',
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showAddAccountDialog(),
                    icon: Icon(Icons.add),
                    label: Text('Create an Account'),
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: accountProvider.accounts.length,
            itemBuilder: (context, index) {
              return _buildAccountTile(accountProvider.accounts[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAccountDialog(),
        icon: Icon(Icons.add),
        label: Text('Add Account'),
      ),
    );
  }

  Widget _buildAccountTile(Account account) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: account.color,
          radius: 25,
          child: Icon(Icons.account_balance, color: Colors.white),
        ),
        title:
            Text(account.name, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${account.accountType} - ${account.accountNumber}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${account.currency} ${account.balance.toStringAsFixed(2)}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 4),
            Text(account.accountType, style: TextStyle(color: Colors.grey)),
          ],
        ),
        onTap: () => _showEditAccountDialog(account),
      ),
    );
  }

  void _showAddAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: EdgeInsets.all(24),
            constraints: BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Add New Account',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 24),
                  _buildAccountForm(),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: Text('Cancel'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      SizedBox(width: 16),
                      ElevatedButton(
                        child: Text('Add'),
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEditAccountDialog(Account account) {
    _name = account.name;
    _accountNumber = account.accountNumber;
    _accountType = account.accountType;
    _balance = account.balance;
    _color = account.color;
    _currency = account.currency;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: EdgeInsets.all(24),
            constraints: BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Edit Account',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 24),
                  _buildAccountForm(isEditing: true),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: Text('Cancel'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      SizedBox(width: 16),
                      ElevatedButton(
                        child: Text('Save'),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            final accountProvider =
                                Provider.of<AccountProvider>(context,
                                    listen: false);
                            accountProvider.updateAccount(
                                account.id,
                                _name,
                                _accountNumber,
                                _accountType,
                                _balance,
                                _color,
                                _currency);
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Account updated successfully'),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                margin: EdgeInsets.all(10),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAccountForm({bool isEditing = false}) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildTextFormField('Account Name', (value) => _name = value!,
              initialValue: isEditing ? _name : null),
          SizedBox(height: 16),
          _buildTextFormField(
              'Account Number', (value) => _accountNumber = value!,
              initialValue: isEditing ? _accountNumber : null),
          SizedBox(height: 16),
          _buildDropdownField(
              'Account Type', _accountTypes, (value) => _accountType = value!,
              initialValue: _accountType),
          SizedBox(height: 16),
          _buildTextFormField(
              'Balance', (value) => _balance = double.parse(value!),
              keyboardType: TextInputType.number,
              initialValue: isEditing ? _balance.toString() : null),
          SizedBox(height: 16),
          _buildDropdownField(
              'Currency', _currencies, (value) => _currency = value!,
              initialValue: _currency),
          SizedBox(height: 16),
          _buildColorPicker(),
        ],
      ),
    );
  }

  Widget _buildTextFormField(String label, Function(String?) onSaved,
      {TextInputType? keyboardType, String? initialValue}) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      initialValue: initialValue,
      keyboardType: keyboardType,
      validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
      onSaved: onSaved,
    );
  }

  Widget _buildDropdownField(
      String label, List<String> items, Function(String?) onChanged,
      {required String initialValue}) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      value: initialValue,
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildColorPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Account Color',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        GestureDetector(
          onTap: _showColorPalette,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: _color,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[300]!),
            ),
          ),
        ),
      ],
    );
  }

  void _showColorPalette() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Account Color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _color,
              onColorChanged: (Color color) {
                setState(() => _color = color);
              },
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
