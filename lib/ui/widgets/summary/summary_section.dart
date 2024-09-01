import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendulum/providers/expense_provider.dart';
import 'package:spendulum/ui/widgets/summary_card.dart';

class SummarySection extends StatelessWidget {
  final String accountId;
  final DateTime selectedMonth;

  const SummarySection(
      {Key? key, required this.accountId, required this.selectedMonth})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, _) {
        final totalExpenses =
            expenseProvider.getTotalExpenses(accountId: accountId);
        // final monthlyBudget = expenseProvider.getMonthlyBudget();
        // final remainingBudget = monthlyBudget - totalExpenses;

        return Column(
          children: [
            SummaryCard(
              title: 'Total Expenses',
              amount: totalExpenses,
              icon: Icons.money_off,
              color: Colors.red,
            ),
            // const SizedBox(height: 16),
            // SummaryCard(
            //   title: 'Remaining Budget',
            //   amount: remainingBudget,
            //   icon: Icons.account_balance_wallet,
            //   color: Colors.green,
            // ),
          ],
        );
      },
    );
  }
}
