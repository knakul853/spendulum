import 'package:flutter/material.dart';
import 'package:spendulum/models/account.dart';
import 'package:spendulum/ui/widgets/monthly_expense_chart.dart';
import 'package:spendulum/features/expenses/widgets/expense_summary_circle.dart';
import 'package:spendulum/features/expenses/widgets/category_expense_chart.dart';

class StatsScreen extends StatelessWidget {
  final Account selectedAccount;

  const StatsScreen({Key? key, required this.selectedAccount})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Statistics',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
                Center(
                  child: SizedBox(
                    width: 230,
                    height: 230,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.primaryColor,
                        boxShadow: [
                          BoxShadow(
                            color: theme.shadowColor.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: ExpenseSummaryCircle(
                          selectedMonth: DateTime.now(),
                          accountId: selectedAccount.id,
                          currency: '\$',
                          size: 230,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: CategoryExpenseChart(
                      selectedAccount: selectedAccount,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          'Expense Trend',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        EnhancedExpenseTrendChart(
                          selectedAccountId: selectedAccount.id,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
