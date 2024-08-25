import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budget_buddy/providers/expense_provider.dart';
import 'package:budget_buddy/providers/category_provider.dart';
import 'package:budget_buddy/providers/account_provider.dart';
import 'package:budget_buddy/models/category.dart';
import 'package:budget_buddy/models/account.dart';
import 'package:intl/intl.dart';

class ExpenseLoggingScreen extends StatefulWidget {
  final String? initialAccountId;

  const ExpenseLoggingScreen({Key? key, this.initialAccountId})
      : super(key: key);

  @override
  _ExpenseLoggingScreenState createState() => _ExpenseLoggingScreenState();
}

class _ExpenseLoggingScreenState extends State<ExpenseLoggingScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _category;
  String? _accountId;
  double _amount = 0.0;
  DateTime _selectedDate = DateTime.now();
  String _description = '';

  @override
  void initState() {
    super.initState();
    _accountId = widget.initialAccountId;
  }

  Future<void> _presentDatePicker() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    if (_category == null || _accountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category and account')),
      );
      return;
    }

    Provider.of<ExpenseProvider>(context, listen: false).addExpense(
      _category!,
      _amount,
      _selectedDate,
      _description,
      _accountId!,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Expense added successfully!')),
    );

    // Navigate back to the previous screen (HomeScreen)
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Expense'),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Theme.of(context).primaryColor, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildAccountDropdown(),
                  const SizedBox(height: 16),
                  _buildCategoryDropdown(),
                  const SizedBox(height: 16),
                  _buildAmountField(),
                  const SizedBox(height: 16),
                  _buildDatePicker(),
                  const SizedBox(height: 16),
                  _buildDescriptionField(),
                  const SizedBox(height: 24),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountDropdown() {
    return Consumer<AccountProvider>(
      builder: (context, accountProvider, child) {
        final accounts = accountProvider.accounts;
        return DropdownButtonFormField<String>(
          value: _accountId,
          decoration: InputDecoration(
            labelText: 'Account',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: Icon(
              Icons.account_balance_wallet,
              color: Theme.of(context).primaryColor,
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          items: accounts.map((account) {
            return DropdownMenuItem(
              value: account.id,
              child: Text(account.name),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _accountId = value;
            });
          },
          validator: (value) =>
              value == null ? 'Please select an account' : null,
        );
      },
    );
  }

  Widget _buildCategoryDropdown() {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        final categories = categoryProvider.categories;
        return DropdownButtonFormField<String>(
          value: _category,
          decoration: InputDecoration(
            labelText: 'Category',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: Icon(
              Icons.category,
              color: Theme.of(context).primaryColor,
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          items: categories.map((category) {
            return DropdownMenuItem(
              value: category.name,
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(int.parse('0xff${category.color}')),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      category.icon,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(category.name),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _category = value;
            });
          },
          validator: (value) =>
              value == null ? 'Please select a category' : null,
        );
      },
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Amount',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: Icon(Icons.attach_money),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty || double.tryParse(value) == null) {
          return 'Please enter a valid amount';
        }
        return null;
      },
      onSaved: (value) {
        _amount = double.parse(value!);
      },
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: _presentDatePicker,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          prefixIcon: Icon(Icons.calendar_today),
          filled: true,
          fillColor: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat.yMd().format(_selectedDate)),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Description',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: Icon(Icons.description),
        filled: true,
        fillColor: Colors.white,
      ),
      maxLines: 3,
      onSaved: (value) {
        _description = value ?? '';
      },
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text('Add Expense'),
      ),
    );
  }
}
