import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendulum/models/account.dart';
import 'package:spendulum/providers/expense_provider.dart';

class CategoryExpenseChart extends StatefulWidget {
  final Account selectedAccount;
  final double size;

  const CategoryExpenseChart({
    Key? key,
    required this.selectedAccount,
    this.size = 300,
  }) : super(key: key);

  @override
  State<CategoryExpenseChart> createState() => _CategoryExpenseChartState();
}

class _CategoryExpenseChartState extends State<CategoryExpenseChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, child) {
        final categoryExpenses = expenseProvider.getExpensesByCategory(
            accountId: widget.selectedAccount.id);

        if (categoryExpenses.isEmpty) {
          return const Center(
              child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No expenses found.'),
          ));
        }

        List<Color> colorList = [
          Colors.blue,
          Colors.yellow,
          Colors.purple,
          Colors.green,
          Colors.red,
          Colors.orange,
          Colors.pink,
          Colors.teal,
          Colors.cyan,
          Colors.amber,
        ];

        return SizedBox(
          height: widget.size,
          child: Column(
            children: <Widget>[
              const SizedBox(height: 10),
              Expanded(
                flex: 3, // Increased flex for the chart
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            touchedIndex = -1;
                            return;
                          }
                          touchedIndex = pieTouchResponse
                              .touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 0,
                    centerSpaceRadius: 0,
                    sections: showingSections(categoryExpenses, colorList),
                  ),
                ),
              ),
              const SizedBox(height: 20), // Spacing between chart and legend
              Expanded(
                flex: 1, // Reduced flex for the legend
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: getLegend(categoryExpenses, colorList),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<PieChartSectionData> showingSections(
      Map<String, double> categoryExpenses, List<Color> colorList) {
    return List.generate(categoryExpenses.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? widget.size * 0.4 : widget.size * 0.35;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

      final entries = categoryExpenses.entries.toList();
      final value = entries[i].value;
      final totalExpenses = categoryExpenses.values.reduce((a, b) => a + b);
      final percentage = (value / totalExpenses * 100).toStringAsFixed(1);

      return PieChartSectionData(
        color: colorList[i % colorList.length],
        value: value,
        title: '$percentage%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.bodyMedium?.color,
          shadows: shadows,
        ),
      );
    });
  }

  List<Widget> getLegend(
      Map<String, double> categoryExpenses, List<Color> colorList) {
    List<Widget> legendItems = [];
    int index = 0;
    categoryExpenses.forEach((category, value) {
      if (index > 0) {
        legendItems.add(const SizedBox(width: 16)); // Add spacing between items
      }
      legendItems.add(
        Indicator(
          color: colorList[index % colorList.length],
          text: category,
          isSquare: false,
        ),
      );
      index++;
    });
    return legendItems;
  }
}

class Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color textColor;

  const Indicator({
    Key? key,
    required this.color,
    required this.text,
    required this.isSquare,
    this.size = 8,
    this.textColor = Colors.black54,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(text, style: Theme.of(context).textTheme.bodySmall)
      ],
    );
  }
}
