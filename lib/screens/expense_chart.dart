import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ExpenseChart extends StatelessWidget {
  final List<Map<String, dynamic>> expenses;

  ExpenseChart({required this.expenses});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: expenses
                  .map((e) =>
                      FlSpot(e['date'].toDouble(), e['amount'].toDouble()))
                  .toList(),
              isCurved: true,
              barWidth: 2,
              color: Colors.blue,
            ),
          ],
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData:
              FlBorderData(show: true, border: Border.all(color: Colors.grey)),
          minX: 0,
          maxX: expenses.length - 1,
          minY: 0,
          maxY: expenses
              .map((e) => e['amount'])
              .toList()
              .reduce((a, b) => a > b ? a : b),
        ),
      ),
    );
  }
}
