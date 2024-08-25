import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class WeeklyBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> weeklyData;

  const WeeklyBarChart({Key? key, required this.weeklyData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                        color: Theme.of(context).textTheme.bodyMedium?.color),
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
                        color: Theme.of(context).textTheme.bodyMedium?.color,
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
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 8,
                      ),
                    );
                  },
                  reservedSize: 40,
                ),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false), // Hide top titles
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false), // Hide right titles
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
  }
}
