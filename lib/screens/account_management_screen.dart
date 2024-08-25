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

  // List of account types
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

  // List of currencies
  final List<String> _currencies = ['USD', 'EUR', 'GBP', 'JPY', 'INR', 'Other'];

  @override
  void initState() {
    super.initState();
    _color = Colors.blue; // Default color
    _accountType = _accountTypes[0]; // Default account type
    _currency = _currencies[0]; // Default currency
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final accountProvider =
          Provider.of<AccountProvider>(context, listen: false);
      accountProvider.addAccount(
          _name, _accountNumber, _accountType, _balance, _color, _currency);
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Account successfully added.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Go back to home screen
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Accounts'),
      ),
      body: Consumer<AccountProvider>(
        builder: (context, accountProvider, child) {
          return ListView.builder(
            itemCount: accountProvider.accounts.length,
            itemBuilder: (context, index) {
              return _buildAccountTile(accountProvider.accounts[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAccountDialog(),
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildAccountTile(Account account) {
    return ListTile(
      leading: CircleAvatar(backgroundColor: account.color),
      title: Text(account.name),
      subtitle: Text('${account.accountType} - ${account.accountNumber}'),
      trailing:
          Text('${account.currency} ${account.balance.toStringAsFixed(2)}'),
      onTap: () => _showEditAccountDialog(account),
    );
  }

  void _showAddAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Account'),
          content: SingleChildScrollView(
            child: _buildAccountForm(),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('Add'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _submitForm();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildAccountForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildTextFormField('Account Name', (value) => _name = value!),
          SizedBox(height: 16),
          _buildTextFormField(
              'Account Number', (value) => _accountNumber = value!),
          SizedBox(height: 16),
          _buildDropdownField(
              'Account Type', _accountTypes, (value) => _accountType = value!),
          SizedBox(height: 16),
          _buildTextFormField(
              'Initial Balance', (value) => _balance = double.parse(value!),
              keyboardType: TextInputType.number),
          SizedBox(height: 16),
          _buildDropdownField(
              'Currency', _currencies, (value) => _currency = value!),
          SizedBox(height: 16),
          _buildColorPicker(),
        ],
      ),
    );
  }

  Widget _buildTextFormField(String label, Function(String?) onSaved,
      {TextInputType? keyboardType}) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
      onSaved: onSaved,
    );
  }

  Widget _buildDropdownField(
      String label, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      value: items[0],
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
    return ListTile(
      title: Text('Account Color'),
      trailing: GestureDetector(
        onTap: _showColorPalette,
        child: CircleAvatar(
          backgroundColor: _color,
          radius: 15,
        ),
      ),
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
                Navigator.of(context).pop();
              },
            ),
          ),
        );
      },
    );
  }

  void _showEditAccountDialog(Account account) {
    // Implement edit account dialog similar to add account dialog
    // Pre-fill the form with existing account details
  }
}
