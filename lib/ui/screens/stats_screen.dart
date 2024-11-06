import 'package:flutter/material.dart';
import 'package:spendulum/models/account.dart';
import 'package:spendulum/ui/widgets/monthly_expense_chart.dart';
import 'package:spendulum/features/expenses/widgets/category_expense_chart.dart';

class StatsScreen extends StatelessWidget {
  final Account selectedAccount;

  const StatsScreen({Key? key, required this.selectedAccount})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Statistics',
          style: theme.textTheme.titleLarge!
              .copyWith(color: theme.colorScheme.onPrimary),
        ),
        elevation: 4,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              theme.colorScheme.secondary.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          'Expense Trend',
                          style: theme.textTheme.titleLarge!.copyWith(
                              color: theme.textTheme.titleMedium?.color),
                        ),
                        SizedBox(height: 16),
                        EnhancedExpenseTrendChart(
                          selectedAccount: selectedAccount,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                      child: Column(
                    children: [
                      Text(
                        'Expense By Categories',
                        style: theme.textTheme.titleLarge!.copyWith(
                            color: theme.textTheme.titleMedium?.color),
                      ),
                      EnhancedCategoryExpenseChart(
                        selectedAccount: selectedAccount,
                      ),
                    ],
                  )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
