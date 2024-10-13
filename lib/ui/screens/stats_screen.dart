import 'package:flutter/material.dart';
import 'package:spendulum/models/account.dart';
import 'package:spendulum/ui/widgets/expenses/expense_summary_circle.dart';
import 'package:spendulum/ui/widgets/animated_background.dart';

class StatsScreen extends StatelessWidget {
  final Account selectedAccount;

  const StatsScreen({Key? key, required this.selectedAccount})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBackground(color: Theme.of(context).primaryColor),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(title: const Text('Statistics')),
          body: Center(
            child: ExpenseSummaryCircle(
              selectedMonth: DateTime.now(),
              accountId: selectedAccount.id,
              size: 140,
              currency: '\$',
            ),
          ),
        ),
      ],
    );
  }
}
