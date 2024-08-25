import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExpenseChart extends StatelessWidget {
  final List<Map<String, dynamic>> monthlyData;

  const ExpenseChart({Key? key, required this.monthlyData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2.70,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 &&
                      value.toInt() < monthlyData.length) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        DateFormat('MMM')
                            .format(monthlyData[value.toInt()]['date']),
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 8,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
                reservedSize: 40,
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
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: true),
          minX: 0,
          maxX: monthlyData.length - 1.0,
          minY: 0,
          maxY: monthlyData
                  .map((e) => e['total'] as double)
                  .reduce((a, b) => a > b ? a : b) *
              1.2,
          lineBarsData: [
            LineChartBarData(
              spots: monthlyData.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value['total']);
              }).toList(),
              isCurved: true,
              color: Theme.of(context).primaryColor,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Theme.of(context).primaryColor.withOpacity(0.2),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
              tooltipRoundedRadius: 8,
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  final flSpot = barSpot;
                  if (flSpot.x.toInt() >= 0 &&
                      flSpot.x.toInt() < monthlyData.length) {
                    final data = monthlyData[flSpot.x.toInt()];
                    return LineTooltipItem(
                      '${DateFormat('MMMM yyyy').format(data['date'])}\n\$${data['total'].toStringAsFixed(2)}',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }
                  return null;
                }).toList();
              },
            ),
            handleBuiltInTouches: true,
          ),
        ),
      ),
    );
  }
}
