import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendulum/providers/expense_provider.dart';
import 'package:intl/intl.dart';
import 'package:spendulum/models/expense.dart';
import 'package:spendulum/features/expenses/widgets/expense_chart.dart';

class MonthlyExpenseChart extends StatelessWidget {
  final String accountId;
  final DateTime selectedMonth;

  const MonthlyExpenseChart(
      {Key? key, required this.accountId, required this.selectedMonth})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, _) {
        final monthlyData = _calculateMonthlyData(expenseProvider.expenses
            .where((e) => e.accountId == accountId)
            .toList());

        if (monthlyData.length < 2) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Monthly Expense Trend',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ExpenseChart(monthlyData: monthlyData),
            ],
          ),
        );
      },
    );
  }
}

List<Map<String, dynamic>> _calculateMonthlyData(List<Expense> expenses) {
  Map<String, double> monthlyTotals = {};

  for (var expense in expenses) {
    String monthKey = DateFormat('yyyy-MM').format(expense.date);
    monthlyTotals[monthKey] = (monthlyTotals[monthKey] ?? 0) + expense.amount;
  }

  List<Map<String, dynamic>> monthlyData = monthlyTotals.entries.map((entry) {
    return {
      'date': DateFormat('yyyy-MM').parse(entry.key),
      'total': entry.value,
    };
  }).toList();

  monthlyData
      .sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

  return monthlyData;
}
