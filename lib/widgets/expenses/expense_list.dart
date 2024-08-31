import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budget_buddy/providers/expense_provider.dart';
import 'package:budget_buddy/widgets/expense_list_item.dart';

class ExpenseList extends StatelessWidget {
  final String accountId;
  final DateTime selectedMonth;

  const ExpenseList({
    Key? key,
    required this.accountId,
    required this.selectedMonth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, _) {
        final expenses = expenseProvider.getExpensesForMonth(selectedMonth,
            accountId: accountId);

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index == 0) {
                // Return the "Latest Spending" header and divider
                return Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Latest Spending',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                ),
                      ),
                      SizedBox(height: 5),
                      Divider(
                          thickness: 1, color: Colors.white.withOpacity(0.5)),
                    ],
                  ),
                );
              } else if (index <= expenses.length) {
                return ExpenseListItem(expense: expenses[index - 1]);
              } else {
                return SizedBox(height: 80); // Adjust this value as needed
              }
              // Return expense list items
            },
            childCount: expenses.length + 2, // +1 for the header
          ),
        );
      },
    );
  }
}
