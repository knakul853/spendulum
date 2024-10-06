import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendulum/constants/app_constants.dart';
import 'package:spendulum/providers/expense_provider.dart';
import 'package:spendulum/providers/category_provider.dart';
import 'package:spendulum/providers/account_provider.dart';
import 'package:intl/intl.dart';
import 'package:spendulum/ui/widgets/animated_background.dart';
import 'package:spendulum/ui/widgets/logger.dart';

class ExpenseLoggingScreen extends StatefulWidget {
  final String? initialAccountId;

  const ExpenseLoggingScreen({Key? key, this.initialAccountId})
      : super(key: key);

  @override
  _ExpenseLoggingScreenState createState() => _ExpenseLoggingScreenState();
}

class _ExpenseLoggingScreenState extends State<ExpenseLoggingScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String? _category;
  String? _accountId;
  double _amount = 0.0;
  DateTime _selectedDate = DateTime.now();
  String _description = '';

  late AnimationController _submitButtonController = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
  );

  @override
  void initState() {
    super.initState();

    AppLogger.info('ExpenseLoggingScreen initialized');
    _accountId = widget.initialAccountId;

    Provider.of<CategoryProvider>(context, listen: false).loadCategories();
  }

  @override
  void didUpdateWidget(ExpenseLoggingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _submitButtonController.dispose();
    super.dispose();
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
        backgroundColor: Colors.transparent, // Make AppBar transparent
        elevation: 0, // Remove shadow
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        // Use Stack to layer the background
        children: [
          AnimatedBackground(
            color: Theme.of(context).primaryColor,
          ),
          Center(
            // Center the form
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
        ],
      ),
    );
  }

  Widget _buildAccountDropdown() {
    return Consumer<AccountProvider>(
      builder: (context, accountProvider, child) {
        final accounts = accountProvider.accounts;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          child: DropdownButtonFormField<String>(
            value: _accountId,
            decoration:
                _getInputDecoration('Account', Icons.account_balance_wallet),
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
          ),
        );
      },
    );
  }

  Widget _buildCategoryDropdown() {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        final categories = categoryProvider.categories;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          child: DropdownButtonFormField<String>(
            value: _category,
            decoration: _getInputDecoration('Category', Icons.category),
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
                        AppConstants.categoryIcons[category.icon.toLowerCase()],
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
          ),
        );
      },
    );
  }

  Widget _buildAmountField() {
    return Consumer<AccountProvider>(
      builder: (context, accountProvider, child) {
        final selectedAccount =
            accountProvider.getAccountById(_accountId ?? '');
        final currencyIcon =
            _getCurrencyIcon(selectedAccount?.currency ?? 'USD');

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          child: TextFormField(
            decoration: _getInputDecoration('Amount', currencyIcon),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null ||
                  value.isEmpty ||
                  double.tryParse(value) == null) {
                return 'Please enter a valid amount';
              }
              return null;
            },
            onSaved: (value) {
              _amount = double.parse(value!);
            },
          ),
        );
      },
    );
  }

  Widget _buildDatePicker() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: InkWell(
        onTap: _presentDatePicker,
        child: InputDecorator(
          decoration: _getInputDecoration('Date', Icons.calendar_today),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(DateFormat.yMd().format(_selectedDate)),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: TextFormField(
        decoration: _getInputDecoration('Description', Icons.description),
        maxLines: 3,
        maxLength: 150,
        onSaved: (value) {
          _description = value ?? '';
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: MouseRegion(
        onEnter: (_) => _submitButtonController.forward(),
        onExit: (_) => _submitButtonController.reverse(),
        child: AnimatedBuilder(
          animation: _submitButtonController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1 + 0.1 * _submitButtonController.value,
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4 + 2 * _submitButtonController.value,
                ),
                child: const Text('Add Expense'),
              ),
            );
          },
        ),
      ),
    );
  }

  InputDecoration _getInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
            color: Theme.of(context).primaryColor.withOpacity(0.5), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
      ),
      prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
      filled: true,
      fillColor: Colors.white,
    );
  }

  IconData _getCurrencyIcon(String currency) {
    switch (currency.toUpperCase()) {
      case 'INR':
        return Icons.currency_rupee;
      case 'USD':
        return Icons.attach_money;
      case 'EUR':
        return Icons.euro;
      case 'GBP':
        return Icons.currency_pound;
      default:
        return Icons.monetization_on;
    }
  }
}
