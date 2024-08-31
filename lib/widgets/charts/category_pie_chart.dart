import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budget_buddy/providers/expense_provider.dart';

class CategoryPieChart extends StatelessWidget {
  final String accountId;
  final DateTime selectedMonth;

  const CategoryPieChart(
      {Key? key, required this.accountId, required this.selectedMonth})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, _) {
        final categoryTotals =
            expenseProvider.getExpensesByCategory(accountId: accountId);

        if (categoryTotals.isEmpty) {
          return const SizedBox.shrink();
        }

        return Card(
          elevation: 8, // Shadow effect
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Rounded corners
          ),
          child: AspectRatio(
            aspectRatio: 1.8,
            child: Padding(
              padding: const EdgeInsets.all(16.0), // Padding inside the card
              child: PieChart(
                PieChartData(
                  sections: _generateSections(context, categoryTotals),
                  sectionsSpace: 0,
                  centerSpaceRadius: 25,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<PieChartSectionData> _generateSections(
      BuildContext context, Map<String, double> categoryTotals) {
    return categoryTotals.entries.map((entry) {
      final color = _getCategoryColor(entry.key);
      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${entry.key}\n${entry.value.toStringAsFixed(2)}',
        radius: 70,
        titleStyle: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
      );
    }).toList();
  }

  Color _getCategoryColor(String category) {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
    ];
    return colors[category.hashCode % colors.length];
  }
}
