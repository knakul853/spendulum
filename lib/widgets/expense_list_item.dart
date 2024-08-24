import 'package:flutter/material.dart';
import 'package:budget_buddy/models/expense.dart';

class ExpenseListItem extends StatelessWidget {
  final Expense expense;

  const ExpenseListItem({Key? key, required this.expense}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(expense.category),
      subtitle: Text(expense.description),
      trailing: Text('\$${expense.amount.toStringAsFixed(2)}'),
      leading: CircleAvatar(
        child: Icon(_getCategoryIcon(expense.category)),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    // Implement logic to return appropriate icon based on category
    return Icons.shopping_cart; // Placeholder
  }
}
