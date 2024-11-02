import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:spendulum/models/budget.dart';
import 'package:spendulum/providers/account_provider.dart';
import 'package:spendulum/providers/category_provider.dart';
import 'package:spendulum/providers/budget_provider.dart';
import 'package:spendulum/ui/widgets/logger.dart';

class AddBudgetDialog extends StatefulWidget {
  const AddBudgetDialog({Key? key}) : super(key: key);

  @override
  State<AddBudgetDialog> createState() => _AddBudgetDialogState();
}

class _AddBudgetDialogState extends State<AddBudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedAccountId;
  List<String> _selectedCategoryIds = [];
  Period _selectedPeriod = Period.monthly;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _rollover = false;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: Container(
        constraints: BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Create New Budget', style: theme.textTheme.titleLarge),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView(
                    children: [
                      _buildNameField(),
                      const SizedBox(height: 16),
                      _buildAccountDropdown(),
                      const SizedBox(height: 16),
                      _buildCategoryMultiSelect(),
                      const SizedBox(height: 16),
                      _buildAmountField(),
                      const SizedBox(height: 16),
                      _buildPeriodDropdown(),
                      const SizedBox(height: 16),
                      _buildDateSection(),
                      const SizedBox(height: 16),
                      _buildRolloverSwitch(),
                      const SizedBox(height: 16),
                      _buildNotesField(),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Create Budget'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Budget Name',
        hintText: 'Enter budget name',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a budget name';
        }
        return null;
      },
    );
  }

  Widget _buildAccountDropdown() {
    return Consumer<AccountProvider>(
      builder: (context, accountProvider, _) {
        final accounts = accountProvider.accounts;
        return DropdownButtonFormField<String>(
          value: _selectedAccountId,
          decoration: const InputDecoration(
            labelText: 'Account',
            hintText: 'Select account',
          ),
          items: accounts.map((account) {
            return DropdownMenuItem(
              value: account.id,
              child: Text(account.name),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedAccountId = value;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please select an account';
            }
            return null;
          },
        );
      },
    );
  }

  Widget _buildCategoryMultiSelect() {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, _) {
        final categories = categoryProvider.categories;
        return InputDecorator(
          decoration: InputDecoration(
            labelText: 'Categories',
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          child: Wrap(
            spacing: 8,
            children: categories.map((category) {
              return FilterChip(
                label: Text(category.name),
                selected: _selectedCategoryIds.contains(category.name),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedCategoryIds.add(category.name);
                    } else {
                      _selectedCategoryIds.remove(category.name);
                    }
                  });
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      decoration: const InputDecoration(
        labelText: 'Budget Amount',
        prefixText: '₹',
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter an amount';
        }
        final amount = double.tryParse(value);
        if (amount == null || amount <= 0) {
          return 'Please enter a valid amount';
        }
        return null;
      },
    );
  }

  Widget _buildPeriodDropdown() {
    return DropdownButtonFormField<Period>(
      value: _selectedPeriod,
      decoration: const InputDecoration(
        labelText: 'Budget Period',
      ),
      items: Period.values.map((period) {
        return DropdownMenuItem(
          value: period,
          child: Text(period.toString().split('.').last.toUpperCase()),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedPeriod = value!;
          if (value != Period.custom) {
            _endDate = null; // Reset end date for non-custom periods
          }
        });
      },
    );
  }

  Widget _buildDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Start Date'),
          subtitle: Text(
            '${_startDate.day}/${_startDate.month}/${_startDate.year}',
          ),
          trailing: IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _startDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                setState(() {
                  _startDate = picked;
                });
              }
            },
          ),
        ),
        if (_selectedPeriod == Period.custom) ...[
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('End Date'),
            subtitle: Text(_endDate != null
                ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                : 'Select end date'),
            trailing: IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _endDate ?? _startDate.add(Duration(days: 1)),
                  firstDate: _startDate.add(Duration(days: 1)),
                  lastDate: _startDate.add(Duration(days: 365)),
                );
                if (picked != null) {
                  setState(() {
                    _endDate = picked;
                  });
                }
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRolloverSwitch() {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('Roll over unused amount'),
      subtitle: const Text('Transfer remaining amount to next period'),
      value: _rollover,
      onChanged: (value) {
        setState(() {
          _rollover = value;
        });
      },
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      decoration: const InputDecoration(
        labelText: 'Notes (Optional)',
        hintText: 'Add any additional notes',
      ),
      maxLines: 3,
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedPeriod == Period.custom && _endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select an end date for custom period'),
          ),
        );
        return;
      }

      try {
        final budgetProvider =
            Provider.of<BudgetProvider>(context, listen: false);

        final amount = double.parse(_amountController.text);
        budgetProvider.addBudget(
          name: _nameController.text,
          accountId: _selectedAccountId!,
          categoryIds: _selectedCategoryIds,
          amount: amount,
          period: _selectedPeriod,
        );

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Budget created successfully')),
        );
      } catch (e) {
        AppLogger.error('Error creating budget', error: e);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error creating budget. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
