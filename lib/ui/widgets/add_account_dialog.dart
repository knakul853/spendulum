import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:spendulum/providers/account_provider.dart';
import 'package:spendulum/constants/app_colors.dart'; // Import AppColors

class AddAccountDialog extends StatefulWidget {
  final Function? onAccountAdded;

  const AddAccountDialog({Key? key, this.onAccountAdded}) : super(key: key);

  @override
  _AddAccountDialogState createState() => _AddAccountDialogState();
}

class _AddAccountDialogState extends State<AddAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _accountNumber = '';
  String _accountType = 'General';
  double _balance = 0.0;
  Color _color = AppColors.primary; // Use AppColors.primary
  String _currency = 'USD';

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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: EdgeInsets.all(24),
        constraints: BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add New Account',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyMedium
                            ?.color)), // Use AppColors.text
                SizedBox(height: 24),
                _buildTextField(
                  'Account Name',
                  (value) => _name = value!,
                  TextInputType.text,
                ), // Corrected to use TextInputType
                SizedBox(height: 16),
                _buildTextField(
                  'Account Number',
                  (value) => _accountNumber = value!,
                  TextInputType.text, // Corrected to use TextInputType
                ), // Use AppColors.text
                SizedBox(height: 16),
                _buildDropdownField(
                    'Account Type',
                    _accountTypes,
                    _accountType,
                    (value) => setState(
                        () => _accountType = value!)), // Use AppColors.text
                SizedBox(height: 16),
                _buildTextField(
                  'Balance',
                  (value) => _balance = double.parse(value!),
                  TextInputType.number,
                ), // Use AppColors.text
                SizedBox(height: 16),
                _buildDropdownField(
                  'Currency',
                  _currencies,
                  _currency,
                  (value) => setState(() => _currency = value!),
                ), // Use AppColors.text
                SizedBox(height: 16),
                _buildColorPicker(),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      child: Text('Cancel',
                          style: TextStyle(
                              color: theme.textTheme.bodySmall
                                  ?.color)), // Use AppColors.text
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        backgroundColor:
                            theme.colorScheme.error, // Use AppColors.error
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                      child: Text('Add',
                          style: TextStyle(
                              color: AppColors.text)), // Use AppColors.text
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        backgroundColor:
                            AppColors.primary, // Use AppColors.primary
                      ),
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

  Widget _buildTextField(String label, Function(String?) onSaved,
      [TextInputType? keyboardType]) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            Theme.of(context).textTheme.labelMedium?.copyWith(fontSize: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: Theme.of(context).primaryColor.withOpacity(0.5), width: 1),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.4),
      ),
      keyboardType: keyboardType,
      validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
      onSaved: onSaved,
      style: TextStyle(
          color: Theme.of(context)
              .textTheme
              .bodySmall
              ?.color), // Use AppColors.text if textColor is null
    );
  }

  Widget _buildDropdownField(String label, List<String> items, String value,
      Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      value: value,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item,
              style: TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color)), // Use textColor
        );
      }).toList(),
      onChanged: onChanged,
      style: TextStyle(
          color: Theme.of(context).textTheme.bodySmall?.color), // Use textColor
    );
  }

  Widget _buildColorPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Account Color',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.text)), // Use AppColors.text
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
            child: Center(
              child: Text(
                'Select Color',
                style: TextStyle(color: Colors.white),
              ),
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
          title: Text('Select Account Color',
              style: TextStyle(color: AppColors.text)), // Use AppColors.text
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
              child: Text('OK',
                  style:
                      TextStyle(color: AppColors.text)), // Use AppColors.text
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final accountProvider =
          Provider.of<AccountProvider>(context, listen: false);
      accountProvider.addAccount(
          _name, _accountNumber, _accountType, _balance, _color, _currency);
      Navigator.of(context).pop();
      if (widget.onAccountAdded != null) {
        widget.onAccountAdded!();
      }
    }
  }
}
