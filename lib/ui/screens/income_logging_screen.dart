import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendulum/providers/income_provider.dart';
import 'package:spendulum/providers/category_provider.dart';
import 'package:spendulum/providers/account_provider.dart';
import 'package:intl/intl.dart';
import 'package:spendulum/ui/widgets/animated_background.dart';
import 'package:spendulum/ui/widgets/logger.dart';

class IncomeLoggingScreen extends StatefulWidget {
  final String? initialAccountId;

  const IncomeLoggingScreen({Key? key, this.initialAccountId})
      : super(key: key);

  @override
  _IncomeLoggingScreenState createState() => _IncomeLoggingScreenState();
}

class _IncomeLoggingScreenState extends State<IncomeLoggingScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String? _source;
  String? _accountId;
  double _amount = 0.0;
  DateTime _selectedDate = DateTime.now();
  String _description = '';

  late AnimationController _submitButtonController;

  @override
  void initState() {
    super.initState();

    AppLogger.info('IncomeLoggingScreen initialized');
    _accountId = widget.initialAccountId;

    _submitButtonController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    Provider.of<CategoryProvider>(context, listen: false).loadCategories();
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

    if (_source == null || _accountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a source and account')),
      );
      return;
    }

    Provider.of<IncomeProvider>(context, listen: false).addIncome(
      _source!,
      _amount,
      _selectedDate,
      _description,
      _accountId!,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Income added successfully!')),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Income'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          AnimatedBackground(
            color: Theme.of(context).primaryColor,
          ),
          Center(
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
                      _buildSourceDropdown(),
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

  Widget _buildSourceDropdown() {
    // You might want to replace this with actual income sources
    final incomeSources = ['Salary', 'Freelance', 'Investment', 'Other'];
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: DropdownButtonFormField<String>(
        value: _source,
        decoration: _getInputDecoration('Source', Icons.source),
        items: incomeSources.map((source) {
          return DropdownMenuItem(
            value: source,
            child: Text(source),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _source = value;
          });
        },
        validator: (value) => value == null ? 'Please select a source' : null,
      ),
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
                child: const Text('Add Income'),
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
