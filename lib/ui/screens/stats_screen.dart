import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendulum/models/account.dart';
import 'package:spendulum/providers/expense_provider.dart';
import 'package:spendulum/ui/widgets/monthly_expense_chart.dart';
import 'package:spendulum/features/expenses/widgets/expense_summary_circle.dart';
import 'package:spendulum/features/expenses/widgets/category_expense_chart.dart';

class StatsScreen extends StatelessWidget {
  final Account selectedAccount;

  const StatsScreen({Key? key, required this.selectedAccount})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Statistics',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade100, Colors.purple.shade100],
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
                        color: Theme.of(context).primaryColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
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
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
