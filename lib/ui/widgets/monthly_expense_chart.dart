import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:spendulum/models/expense.dart';
import 'package:spendulum/providers/expense_provider.dart';
import 'package:spendulum/ui/widgets/logger.dart';
import 'package:spendulum/features/expenses/widgets/expense_bar_chart.dart';
import 'package:spendulum/models/account.dart';
import 'package:spendulum/utils/currency.dart';

class EnhancedExpenseTrendChart extends StatefulWidget {
  final Account selectedAccount;

  const EnhancedExpenseTrendChart({
    Key? key,
    required this.selectedAccount,
  }) : super(key: key);

  @override
  _EnhancedExpenseTrendChartState createState() =>
      _EnhancedExpenseTrendChartState();
}

class _EnhancedExpenseTrendChartState extends State<EnhancedExpenseTrendChart> {
  DateTime startDate = DateTime.now().subtract(const Duration(days: 365));
  DateTime endDate = DateTime.now();
  String selectedPeriod = 'Weekly';
  bool showLineChart = true;

  @override
  void initState() {
    super.initState();
    _updateDateRange();
  }

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
                selectedAccount: widget.selectedAccount,
                startDate: startDate,
                endDate: endDate,
                period: selectedPeriod,
              )
            : ExpenseBarChart(
                selectedAccountId: widget.selectedAccount.id,
                startDate: startDate,
                endDate: endDate,
                period: selectedPeriod,
              ),
      ),
    );
  }

  //Original _updateDateRange method
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

class _ExpenseTrendChart extends StatefulWidget {
  final Account selectedAccount;
  final DateTime startDate;
  final DateTime endDate;
  final String period;

  const _ExpenseTrendChart({
    required this.selectedAccount,
    required this.startDate,
    required this.endDate,
    required this.period,
  });

  @override
  State<_ExpenseTrendChart> createState() => _ExpenseTrendChartState();
}

class _ExpenseTrendChartState extends State<_ExpenseTrendChart> {
  bool hasError = false;
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, child) {
        return FutureBuilder<List<Expense>>(
          future: expenseProvider.getExpensesForAccountAndDateRange(
            widget.selectedAccount.id,
            widget.startDate,
            widget.endDate,
          ),
          builder: (context, snapshot) {
            // Handle loading state
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading expense data...'),
                  ],
                ),
              );
            }

            // Handle error state
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading expenses',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {});
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            // Handle empty data state
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.analytics_outlined,
                      size: 48,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No expenses found for this period',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              );
            }

            final expenses = snapshot.data!;
            final groupedExpenses = _groupExpenses(expenses);

            if (groupedExpenses.isEmpty) {
              return const Center(
                child: Text('No expenses to display'),
              );
            }

            return LineChart(
              _createChartData(groupedExpenses,
                  getCurrencySymbol(widget.selectedAccount.currency), context),
              duration: const Duration(milliseconds: 250),
            );
          },
        );
      },
    );
  }

  LineChartData _createChartData(Map<String, double> groupedExpenses,
      String currency, BuildContext context) {
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
            color: Theme.of(context).colorScheme.onSurface,
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
            getTitlesWidget: (value, meta) =>
                _leftTitleWidgets(value, currency, context),
          ),
        ),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 1,
          ),
          left: BorderSide(
            color: Colors.transparent,
          ),
          right: BorderSide(
            color: Colors.transparent,
          ),
          top: BorderSide(
            color: Colors.transparent,
          ),
        ),
      ),
      minX: 0,
      maxX: (groupedExpenses.length - 1).toDouble(),
      minY: 0,
      maxY: maxY,
      clipData: FlClipData.none(),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          preventCurveOverShooting: true,
          color: Theme.of(context).textTheme.bodyMedium?.color,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color:
                Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.2),
            cutOffY: 0,
            applyCutOffY: true,
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
                '$date: $currency${touchedSpot.y.toStringAsFixed(2)}',
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
            color: Theme.of(context).textTheme.bodyMedium?.color,
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

  /// Generates left title widgets for the line chart.
  ///
  /// The title is the integer value of [value] prefixed with a dollar sign.
  ///
  /// The style of the title is determined by [Theme.of(context).textTheme.bodySmall].
  ///
  /// The title is right-aligned.
  Widget _leftTitleWidgets(
      double value, String currency, BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall;
    return Text('$currency${value.toInt()}',
        style: style, textAlign: TextAlign.right);
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
    //Added log for debugging
    AppLogger.info("The expenses are: $expenses");
    for (Expense expense in expenses) {
      AppLogger.info(
          "The grouped expense duration is ${expense.date} and expense is ${expense.amount}");
    }
    switch (widget.period) {
      case 'Weekly':
        for (int i = 0; i < 7; i++) {
          final day = widget.endDate.subtract(Duration(days: 6 - i));
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
        final today = DateTime.now();
        final startDate = today.subtract(const Duration(days: 30));

        for (int i = 0; i <= 30; i += 7) {
          final weekStart = startDate.add(Duration(days: i));

          // Stop if the weekStart exceeds today
          if (weekStart.isAfter(today)) break;

          // Calculate the weekEnd as 6 days from weekStart, capped at today if necessary
          final weekEnd = weekStart.add(const Duration(days: 6));
          final validEndDate = weekEnd.isAfter(today) ? today : weekEnd;

          // Filter expenses within the week, only for this specific range
          final weekExpenses = expenses.where((e) =>
              e.date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
              e.date.isBefore(validEndDate.add(const Duration(days: 1))));

          // Sum up the weekly expenses
          final sum = weekExpenses.fold(0.0, (sum, e) => sum + e.amount);

          // Use both weekStart and validEndDate for clear range in key
          final key =
              "${DateFormat('d').format(weekStart)}-${DateFormat('d MMM').format(validEndDate)}";
          groupedExpenses[key] = sum;
          AppLogger.info(
              "Week starting: ${DateFormat('MMM d').format(weekStart)}, Sum: $sum");
        }
        break;
      case 'Yearly':
        final today = DateTime.now();
        final currentMonth = today.month;

        for (int month = 1; month <= currentMonth; month++) {
          final monthStart = DateTime(widget.startDate.year, month, 1);
          final monthEnd = DateTime(widget.startDate.year, month + 1, 0);

          // Filter expenses within the month
          final monthExpenses = expenses.where((e) =>
              e.date.isAfter(monthStart.subtract(const Duration(days: 1))) &&
              e.date.isBefore(monthEnd.add(const Duration(days: 1))));

          // Sum up the monthly expenses
          final sum = monthExpenses.fold(0.0, (sum, e) => sum + e.amount);

          // Format key as "Jan" or another abbreviation for the month
          final key = DateFormat('MMM').format(monthStart);
          groupedExpenses[key] = sum;

          AppLogger.info(
              "Month: ${DateFormat('d MMM').format(monthStart)} - ${DateFormat('d MMM').format(monthEnd)}, Sum: $sum");
        }
        break;
    }

    AppLogger.info("The expense for the period is: $groupedExpenses");

    return groupedExpenses;
  }
}
