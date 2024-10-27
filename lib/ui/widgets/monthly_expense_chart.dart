import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:spendulum/models/expense.dart';
import 'package:spendulum/providers/expense_provider.dart';
import 'package:spendulum/ui/widgets/logger.dart';
import 'package:spendulum/features/expenses/widgets/expense_bar_chart.dart';

class EnhancedExpenseTrendChart extends StatefulWidget {
  final String selectedAccountId;

  const EnhancedExpenseTrendChart({
    Key? key,
    required this.selectedAccountId,
  }) : super(key: key);

  @override
  _EnhancedExpenseTrendChartState createState() =>
      _EnhancedExpenseTrendChartState();
}

class _EnhancedExpenseTrendChartState extends State<EnhancedExpenseTrendChart> {
  DateTime startDate = DateTime.now().subtract(const Duration(days: 365));
  DateTime endDate = DateTime.now();
  String selectedPeriod = 'Yearly';
  bool showLineChart = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildPeriodSelector(),
        //TODO: implement the complexity of selecting dynamic date range later on.
        //_buildDateRangeDisplay(),
        //  _buildChartTypeSelector(),

        _buildChart(),
      ],
    );
  }

  Widget _buildChartTypeSelector() {
    return SegmentedButton<bool>(
      segments: const [
        ButtonSegment(value: true, label: Text('Line Chart')),
        ButtonSegment(value: false, label: Text('Bar Chart')),
      ],
      selected: {showLineChart},
      onSelectionChanged: (Set<bool> newSelection) {
        setState(() {
          showLineChart = newSelection.first;
        });
      },
    );
  }

  Widget _buildPeriodSelector() {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: 'Weekly', label: Text('Weekly')),
        ButtonSegment(value: 'Monthly', label: Text('Monthly')),
        ButtonSegment(value: 'Yearly', label: Text('Yearly')),
      ],
      selected: {selectedPeriod},
      onSelectionChanged: (Set<String> newSelection) {
        setState(() {
          selectedPeriod = newSelection.first;
          _updateDateRange();
        });
      },
    );
  }

  Widget _buildDateRangeDisplay() {
    return TextButton(
      onPressed: _selectDateRange,
      child: Text(
        '${DateFormat('MMM d, y').format(startDate)} - ${DateFormat('MMM d, y').format(endDate)}',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }

  Widget _buildChart() {
    return AspectRatio(
      aspectRatio: 1.70,
      child: Padding(
        padding: const EdgeInsets.only(right: 16, left: 6, top: 16, bottom: 6),
        child: showLineChart
            ? _ExpenseTrendChart(
                selectedAccountId: widget.selectedAccountId,
                startDate: startDate,
                endDate: endDate,
                period: selectedPeriod,
              )
            : ExpenseBarChart(
                selectedAccountId: widget.selectedAccountId,
                startDate: startDate,
                endDate: endDate,
                period: selectedPeriod,
              ),
      ),
    );
  }

  void _updateDateRange() {
    final now = DateTime.now();
    switch (selectedPeriod) {
      case 'Weekly':
        endDate = now;
        startDate = now.subtract(const Duration(days: 6));
        break;
      case 'Monthly':
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 0);
        break;
      case 'Yearly':
        startDate = DateTime(now.year, 1, 1);
        endDate = now;
        break;
    }
    setState(() {});
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: startDate, end: endDate),
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
        // Ensure endDate is not after DateTime.now()
        if (endDate.isAfter(DateTime.now())) {
          endDate = DateTime.now();
        }
        selectedPeriod = 'Custom';
      });
    }
  }
}

class _ExpenseTrendChart extends StatelessWidget {
  final String selectedAccountId;
  final DateTime startDate;
  final DateTime endDate;
  final String period;

  const _ExpenseTrendChart({
    required this.selectedAccountId,
    required this.startDate,
    required this.endDate,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, child) {
        return FutureBuilder<List<Expense>>(
          future: expenseProvider.getExpensesForAccountAndDateRange(
            selectedAccountId,
            startDate,
            endDate,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('No expenses found for this period');
            }

            final expenses = snapshot.data!;
            final groupedExpenses = _groupExpenses(expenses);

            //Added this check to prevent error when groupedExpenses is empty
            if (groupedExpenses.isNotEmpty) {
              return LineChart(
                _createChartData(groupedExpenses, context),
                duration: const Duration(milliseconds: 250),
              );
            } else {
              return const Text('No expenses found for this period');
            }
          },
        );
      },
    );
  }

  /// Groups expenses by period.
  ///
  /// The period is determined by the `period` argument.
  ///
  /// For 'Weekly', the expenses are grouped by day of week.
  ///
  /// For 'Monthly', the expenses are grouped by week of month.
  ///
  /// For 'Yearly', the expenses are grouped by month of year.
  ///
  /// The returned map has the period as the key and the sum of the expenses
  /// for that period as the value.
  Map<String, double> _groupExpenses(List<Expense> expenses) {
    final groupedExpenses = <String, double>{};
    final now = DateTime.now();
    final currentMonth = now.month;
    for (Expense expense in expenses) {
      AppLogger.info(
          "The grouped expense duration is ${expense.date} and expense is ${expense.amount}");
    }
    switch (period) {
      case 'Weekly':
        for (int i = 0; i < 7; i++) {
          final day = endDate.subtract(Duration(days: 6 - i));
          final dayExpenses = expenses.where((e) =>
              e.date.year == day.year &&
              e.date.month == day.month &&
              e.date.day == day.day);
          final sum = dayExpenses.fold(0.0, (sum, e) => sum + e.amount);
          groupedExpenses[DateFormat('E').format(day)] = sum;
          AppLogger.info(
              "Day: ${DateFormat('E, MMM d').format(day)}, Sum: $sum");
        }
        break;
      case 'Monthly':
        final daysInMonth =
            DateUtils.getDaysInMonth(startDate.year, startDate.month);
        for (int i = 1; i <= daysInMonth; i += 7) {
          final weekStart = DateTime(startDate.year, startDate.month, i);
          final weekEnd = weekStart.add(const Duration(days: 6));
          final weekExpenses = expenses.where((e) =>
              e.date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
              e.date.isBefore(weekEnd.add(const Duration(days: 1))));
          final sum = weekExpenses.fold(0.0, (sum, e) => sum + e.amount);
          groupedExpenses[DateFormat('d').format(weekStart)] = sum;
          AppLogger.info(
              "Week starting: ${DateFormat('MMM d').format(weekStart)}, Sum: $sum");
        }
        break;
      case 'Yearly':
        for (int month = 1; month <= currentMonth; month++) {
          final monthStart = DateTime(startDate.year, month, 1);
          final monthEnd = DateTime(startDate.year, month + 1, 0);
          final monthExpenses = expenses.where((e) =>
              e.date.isAfter(monthStart.subtract(const Duration(days: 1))) &&
              e.date.isBefore(monthEnd.add(const Duration(days: 1))));
          final sum = monthExpenses.fold(0.0, (sum, e) => sum + e.amount);
          groupedExpenses[DateFormat('MMM').format(monthStart)] = sum;
          AppLogger.info(
              "Month: ${DateFormat('MMM').format(monthStart)}, Sum: $sum");
        }
        break;
    }

    AppLogger.info("The expense for the period is: $groupedExpenses");

    return groupedExpenses;
  }

  DateFormat _getDateFormat() {
    switch (period) {
      case 'Weekly':
        return DateFormat('E');
      case 'Monthly':
        return DateFormat('d');
      case 'Yearly':
      default:
        return DateFormat('MMM');
    }
  }

  LineChartData _createChartData(
      Map<String, double> groupedExpenses, BuildContext context) {
    final spots = groupedExpenses.entries
        .map((e) => FlSpot(
              groupedExpenses.keys.toList().indexOf(e.key).toDouble(),
              e.value,
            ))
        .toList();

    final maxY = groupedExpenses.values
            .reduce((max, value) => max > value ? max : value) *
        1.2;

    return LineChartData(
      gridData: FlGridData(
        show: false,
        drawVerticalLine: false,
        horizontalInterval: maxY / 5, // Adjust interval based on max value
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.black12,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 22,
            interval: 1,
            getTitlesWidget: (value, meta) => _bottomTitleWidgets(
                value, groupedExpenses.keys.toList(), context),
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            interval: maxY / 5, // Adjust interval based on max value
            getTitlesWidget: (value, meta) => _leftTitleWidgets(value, context),
          ),
        ),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: (groupedExpenses.length - 1).toDouble(),
      minY: 0,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Theme.of(context).primaryColor,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: Theme.of(context).primaryColor.withOpacity(0.2),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Theme.of(context).cardColor,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((LineBarSpot touchedSpot) {
              final date = groupedExpenses.keys.toList()[touchedSpot.x.toInt()];
              return LineTooltipItem(
                '${date}: \$${touchedSpot.y.toStringAsFixed(2)}',
                TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
              );
            }).toList();
          },
        ),
        handleBuiltInTouches: true,
      ),
      extraLinesData: ExtraLinesData(
        horizontalLines: [
          HorizontalLine(
            y: 0,
            color: Colors.black26,
            strokeWidth: 1,
          ),
        ],
      ),
    );
  }

  Widget _bottomTitleWidgets(
      double value, List<String> dates, BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall;
    final index = value.toInt();
    if (index >= 0 && index < dates.length) {
      return SideTitleWidget(
        axisSide: AxisSide.bottom,
        child: Text(dates[index], style: style),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _leftTitleWidgets(double value, BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall;
    return Text('\$${value.toInt()}', style: style, textAlign: TextAlign.right);
  }
}
