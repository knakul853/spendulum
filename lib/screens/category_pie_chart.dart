import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CategoryPieChart extends StatelessWidget {
  final Map<String, double> categoryTotals;

  const CategoryPieChart({Key? key, required this.categoryTotals})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.8,
      child: PieChart(
        PieChartData(
          sections: _generateSections(context, categoryTotals),
          sectionsSpace: 0,
          centerSpaceRadius: 25,
        ),
      ),
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
        radius: 100,
        titleStyle: TextStyle(
          fontSize: 12,
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
