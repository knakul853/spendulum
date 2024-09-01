import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendulum/providers/expense_provider.dart';
import 'package:spendulum/widgets/expense_list_item.dart';
import 'package:spendulum/providers/account_provider.dart';

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
        final accountProvider =
            Provider.of<AccountProvider>(context); // Get account provider

        final accountCurrency = accountProvider.getCurrencyCode(accountId);

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (expenses.isEmpty) {
                // Check if there are no expenses
                return Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No Spending Found', // Display message when no expenses
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 1.5, // Add letter spacing
                            ),
                      ),
                      SizedBox(height: 5),
                      Divider(
                          thickness: 1,
                          color: Colors.white.withOpacity(0.5)), // Show divider
                    ],
                  ),
                );
              } else if (index == 0) {
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
                          thickness: 1,
                          color: Colors.white.withOpacity(0.5)), // Show divider
                    ],
                  ),
                );
              } else if (index <= expenses.length) {
                return ExpenseListItem(
                  expense: expenses[index - 1],
                  currency: accountCurrency,
                );
              } else {
                return SizedBox(height: 80); // Adjust this value as needed
              }
              // Return expense list items
            },
            childCount: expenses.isEmpty
                ? 1
                : expenses.length + 2, // Adjust childCount for no expenses
          ),
        );
      },
    );
  }
}
