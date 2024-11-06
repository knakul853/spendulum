import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendulum/models/account.dart';
import 'package:spendulum/providers/expense_provider.dart';
import 'package:spendulum/utils/currency.dart';
import 'package:spendulum/models/expense.dart';
import 'package:spendulum/ui/widgets/common/period_selector.dart';

class EnhancedCategoryExpenseChart extends StatefulWidget {
  final Account selectedAccount;
  final double size;

  const EnhancedCategoryExpenseChart({
    Key? key,
    required this.selectedAccount,
    this.size = 300,
  }) : super(key: key);

  @override
  State<EnhancedCategoryExpenseChart> createState() =>
      _EnhancedCategoryExpenseChartState();
}

class _EnhancedCategoryExpenseChartState
    extends State<EnhancedCategoryExpenseChart> {
  int touchedIndex = -1;
  String selectedPeriod = 'Monthly';
  DateTime startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime endDate = DateTime.now();

  static const List<Color> chartColors = [
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

  @override
  void initState() {
    super.initState();
    _updateDateRange();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PeriodSelector(
          selectedPeriod: selectedPeriod,
          onPeriodChanged: _handlePeriodChange,
          startDate: startDate,
          endDate: endDate,
          onDateRangeSelect: _selectDateRange,
          showDateRange: true,
        ),
        _buildCategoryChart(),
      ],
    );
  }

  Widget _buildCategoryChart() {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, child) {
        return FutureBuilder<List<Expense>>(
          future: expenseProvider.getExpensesForAccountAndDateRange(
            widget.selectedAccount.id,
            startDate,
            endDate,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return ChartErrorWidget(
                error: snapshot.error.toString(),
                onRetry: () => setState(() {}),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const ChartEmptyWidget();
            }

            return _buildChartContent(snapshot.data!);
          },
        );
      },
    );
  }

  Widget _buildChartContent(List<Expense> expenses) {
    final categoryData = _processExpenseData(expenses);

    return SizedBox(
      height: widget.size,
      child: Column(
        children: <Widget>[
          const SizedBox(height: 20),
          Expanded(
            flex: 3,
            child: _buildPieChart(categoryData),
          ),
          const SizedBox(height: 20),
          Expanded(
            flex: 1,
            child: _buildLegend(categoryData),
          ),
        ],
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

  void _handlePeriodChange(String newPeriod) {
    setState(() {
      selectedPeriod = newPeriod;
      _updateDateRange();
    });
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
        if (endDate.isAfter(DateTime.now())) {
          endDate = DateTime.now();
        }
        selectedPeriod = 'Custom';
      });
    }
  }

  void _handleChartTouch(
      FlTouchEvent event, PieTouchResponse? pieTouchResponse) {
    // setState(() {
    //   if (!event.isInterestedForInteractions ||
    //       pieTouchResponse == null ||
    //       pieTouchResponse.touchedSection == null) {
    //     touchedIndex = -1;
    //     return;
    //   }
    //   touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
    // });
  }

  Widget _buildPieChart(Map<String, ExpenseCategoryData> categoryData) {
    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(touchCallback: _handleChartTouch),
        borderData: FlBorderData(show: false),
        sectionsSpace: 0,
        centerSpaceRadius: 0,
        sections: _createPieSections(categoryData),
      ),
    );
  }

  List<PieChartSectionData> _createPieSections(
      Map<String, ExpenseCategoryData> categoryData) {
    return categoryData.entries.map((entry) {
      final index = categoryData.keys.toList().indexOf(entry.key);
      final isTouched = index == touchedIndex;

      return PieChartSectionData(
        color: entry.value.color,
        value: entry.value.amount,
        title: '${entry.value.percentage.toStringAsFixed(1)}%',
        radius: isTouched ? widget.size * 0.4 : widget.size * 0.35,
        titleStyle: _getSectionTextStyle(isTouched),
        badgeWidget: isTouched ? _createBadgeWidget(entry.value.amount) : null,
        badgePositionPercentageOffset: 1.2,
      );
    }).toList();
  }

  TextStyle _getSectionTextStyle(bool isTouched) {
    return TextStyle(
      fontSize: isTouched ? 25.0 : 16.0,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).textTheme.bodyMedium?.color,
      shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
    );
  }

  Widget _createBadgeWidget(double amount) {
    return Text(
      '${getCurrencySymbol(widget.selectedAccount.currency)}${amount.toStringAsFixed(0)}',
      style: TextStyle(
        color: Theme.of(context).textTheme.bodyMedium?.color,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildLegend(Map<String, ExpenseCategoryData> categoryData) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _createLegendItems(categoryData),
      ),
    );
  }

  Map<String, ExpenseCategoryData> _processExpenseData(List<Expense> expenses) {
    final Map<String, double> categoryTotals = {};
    double total = 0;

    for (var expense in expenses) {
      categoryTotals.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
      total += expense.amount;
    }

    final Map<String, ExpenseCategoryData> categoryData = {};
    categoryTotals.forEach((category, amount) {
      categoryData[category] = ExpenseCategoryData(
        amount: amount,
        percentage: (amount / total) * 100,
        color: chartColors[categoryData.length % chartColors.length],
      );
    });

    return Map.fromEntries(
      categoryData.entries.toList()
        ..sort((a, b) => b.value.amount.compareTo(a.value.amount)),
    );
  }

  List<Widget> _createLegendItems(
      Map<String, ExpenseCategoryData> categoryData) {
    return categoryData.entries.map((entry) {
      final formattedAmount = entry.value.amount.toStringAsFixed(2);
      final percentage = entry.value.percentage.toStringAsFixed(1);

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Tooltip(
          message:
              'Total: ${getCurrencySymbol(widget.selectedAccount.currency)}$formattedAmount',
          child: CategoryIndicator(
            color: entry.value.color,
            category: entry.key,
            details:
                ' (${getCurrencySymbol(widget.selectedAccount.currency)}$formattedAmount - $percentage%)',
          ),
        ),
      );
    }).toList();
  }
}

// New class to hold category data
class ExpenseCategoryData {
  final double amount;
  final double percentage;
  final Color color;

  ExpenseCategoryData({
    required this.amount,
    required this.percentage,
    required this.color,
  });
}

// Extracted to a separate widget
class CategoryIndicator extends StatelessWidget {
  final Color color;
  final String category;
  final String details;
  final double size;

  const CategoryIndicator({
    Key? key,
    required this.color,
    required this.category,
    required this.details,
    this.size = 8,
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
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          category,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          details,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

// Shared widgets to be placed in separate files
class ChartErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const ChartErrorWidget({
    Key? key,
    required this.error,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            error,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class ChartEmptyWidget extends StatelessWidget {
  const ChartEmptyWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
}
