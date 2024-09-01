import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:spendulum/providers/expense_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class WeeklyBarChart extends StatelessWidget {
  final String accountId;
  final DateTime selectedMonth;

  const WeeklyBarChart(
      {Key? key, required this.accountId, required this.selectedMonth})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, _) {
        final weeklyData = _calculateWeeklyData(context, expenseProvider);

        if (weeklyData.isEmpty ||
            weeklyData.every((data) => data['total'] == 0.0)) {
          return const SizedBox.shrink();
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white, // Background color of the chart area
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 3,
                blurRadius: 5,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
            borderRadius: BorderRadius.circular(12), // Corner radius
          ),
          padding: EdgeInsets.all(16), // Padding around the chart

          child: AspectRatio(
            aspectRatio: 2.5,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                gridData: FlGridData(
                  show: false, // Ensure grid lines are not shown
                ),
                maxY: weeklyData
                        .map((e) => e['total'] as double)
                        .reduce((a, b) => a > b ? a : b) *
                    1.2,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Theme.of(context).cardColor,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${weeklyData[groupIndex]['day']}\n\$${rod.toY.toStringAsFixed(2)}',
                        TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          weeklyData[value.toInt()]['day'],
                          style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 8,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '\$${value.toInt()}',
                          style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 8,
                          ),
                        );
                      },
                      reservedSize: 40,
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles:
                        SideTitles(showTitles: false), // Hide top titles
                  ),
                  rightTitles: AxisTitles(
                    sideTitles:
                        SideTitles(showTitles: false), // Hide right titles
                  ),
                ),
                borderData: FlBorderData(
                  show: false, // Hide grid lines and borders
                ),
                barGroups: weeklyData.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value['total'],
                        color: Theme.of(context).primaryColor,
                        width: 15,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _calculateWeeklyData(
      BuildContext context, ExpenseProvider expenseProvider) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekDays =
        List.generate(7, (index) => weekStart.add(Duration(days: index)));

    return weekDays.map((day) {
      final dayExpenses = expenseProvider.expenses.where((expense) =>
          expense.date.year == day.year &&
          expense.date.month == day.month &&
          expense.date.day == day.day &&
          expense.accountId == accountId);
      return {
        'day': DateFormat('EEE').format(day),
        'total': dayExpenses.fold(0.0, (sum, expense) => sum + expense.amount),
      };
    }).toList();
  }
}
