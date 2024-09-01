import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:spendulum/providers/account_provider.dart';

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
  Color _color = Colors.blue;
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
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 24),
                _buildTextField('Account Name', (value) => _name = value!),
                SizedBox(height: 16),
                _buildTextField(
                    'Account Number', (value) => _accountNumber = value!),
                SizedBox(height: 16),
                _buildDropdownField('Account Type', _accountTypes, _accountType,
                    (value) => setState(() => _accountType = value!)),
                SizedBox(height: 16),
                _buildTextField(
                    'Balance',
                    (value) => _balance = double.parse(value!),
                    TextInputType.number),
                SizedBox(height: 16),
                _buildDropdownField('Currency', _currencies, _currency,
                    (value) => setState(() => _currency = value!)),
                SizedBox(height: 16),
                _buildColorPicker(),
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
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
      ),
    );
  }

  Widget _buildTextField(String label, Function(String?) onSaved,
      [TextInputType? keyboardType]) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      keyboardType: keyboardType,
      validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
      onSaved: onSaved,
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
          child: Text(item),
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
