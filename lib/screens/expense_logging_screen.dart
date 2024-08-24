import 'package:budget_buddy/models/category.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budget_buddy/providers/expense_provider.dart';
import 'package:budget_buddy/providers/category_provider.dart';
import 'package:intl/intl.dart';

class ExpenseLoggingScreen extends StatefulWidget {
  const ExpenseLoggingScreen({Key? key}) : super(key: key);

  @override
  _ExpenseLoggingScreenState createState() => _ExpenseLoggingScreenState();
}

class _ExpenseLoggingScreenState extends State<ExpenseLoggingScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _category;
  double _amount = 0.0;
  DateTime _selectedDate = DateTime.now();
  String _description = '';

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

    if (_category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    Provider.of<ExpenseProvider>(context, listen: false).addExpense(
      _category!,
      _amount,
      _selectedDate,
      _description,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Expense added successfully!')),
    );

    // Clear form after submission
    _formKey.currentState!.reset();
    setState(() {
      _category = null;
      _selectedDate = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Expense'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
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
            fillColor: Colors.grey[100],
            contentPadding:
                const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
          ),
          items: categories.map((category) {
            return DropdownMenuItem(
              value: category.name,
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    margin: EdgeInsets.symmetric(vertical: 10), // Added margin
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
                  Expanded(
                    child: Text(
                      category.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _category = value;
            });
          },
          selectedItemBuilder: (BuildContext context) {
            return categories.map<Widget>((Category category) {
              return Container(
                alignment: Alignment.centerLeft,
                constraints: BoxConstraints(minHeight: 240),
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
                        size: 18,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        category.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList();
          },
          validator: (value) =>
              value == null ? 'Please select a category' : null,
          icon: Icon(Icons.arrow_drop_down_circle,
              color: Theme.of(context).primaryColor),
          isExpanded: true,
          dropdownColor: Colors.lightBlue[100],
          style: TextStyle(color: Colors.black87, fontSize: 16),
        );
      },
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Amount',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.attach_money),
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
        decoration: const InputDecoration(
          labelText: 'Date',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.calendar_today),
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
      decoration: const InputDecoration(
        labelText: 'Description',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.description),
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
        ),
        child: const Text('Add Expense'),
      ),
    );
  }
}
