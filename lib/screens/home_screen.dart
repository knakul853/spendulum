import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budget_buddy/providers/expense_provider.dart';
import 'package:budget_buddy/screens/expense_logging_screen.dart';
import 'package:budget_buddy/screens/category_management_screen.dart';
import 'package:budget_buddy/widgets/expense_list_item.dart';
import 'package:budget_buddy/widgets/summary_card.dart';
import 'package:budget_buddy/widgets/action_button.dart';
import 'package:budget_buddy/screens/expense_chart.dart';
import 'package:budget_buddy/screens/category_pie_chart.dart';
import 'package:budget_buddy/screens/weekly_bar_chart.dart';
import "package:budget_buddy/models/expense.dart";
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          _buildMonthlyExpenseChart(context),
          _buildCategoryPieChart(context),
          _buildWeeklyBarChart(context),
          _buildSummarySection(),
          _buildExpenseList(),
        ],
      ),
      floatingActionButton: _buildAddExpenseButton(context),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 110.0,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text('Budget Buddy'),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColorLight
              ],
            ),
          ),
        ),
      ),
      actions: [
        ActionButton(
          icon: Icons.category,
          onPressed: () =>
              _navigateTo(context, const CategoryManagementScreen()),
        ),
      ],
    );
  }

  Widget _buildSummarySection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<ExpenseProvider>(
          builder: (context, expenseProvider, child) {
            final totalExpenses = expenseProvider.getTotalExpenses();
            final monthlyBudget = expenseProvider.getMonthlyBudget();
            final remainingBudget = monthlyBudget - totalExpenses;

            return Column(
              children: [
                SummaryCard(
                  title: 'Total Expenses',
                  amount: totalExpenses,
                  icon: Icons.money_off,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                SummaryCard(
                  title: 'Remaining Budget',
                  amount: remainingBudget,
                  icon: Icons.account_balance_wallet,
                  color: Colors.green,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildExpenseList() {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, child) {
        final expenses = expenseProvider.expenses;
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final expense = expenses[index];
              return ExpenseListItem(expense: expense);
            },
            childCount: expenses.length,
          ),
        );
      },
    );
  }

  Widget _buildMonthlyExpenseChart(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, child) {
        final monthlyData = _calculateMonthlyData(expenseProvider.expenses);

        // Check if there is data for at least 2 months
        if (monthlyData.length < 2) {
          return const SliverToBoxAdapter(
            child: SizedBox
                .shrink(), // Returns an empty widget when not enough data
          );
        }

        // If enough data, show the chart and the title
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monthly Expense Trend',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: 8),
                ExpenseChart(monthlyData: monthlyData),
              ],
            ),
          ),
        );
      },
    );
  }

// The helper method to calculate monthly data
  List<Map<String, dynamic>> _calculateMonthlyData(List<Expense> expenses) {
    Map<String, double> monthlyTotals = {};

    for (var expense in expenses) {
      String monthKey = DateFormat('yyyy-MM').format(expense.date);
      monthlyTotals[monthKey] = (monthlyTotals[monthKey] ?? 0) + expense.amount;
    }

    List<Map<String, dynamic>> monthlyData = monthlyTotals.entries.map((entry) {
      return {
        'date': DateFormat('yyyy-MM').parse(entry.key),
        'total': entry.value,
      };
    }).toList();

    monthlyData.sort(
        (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

    return monthlyData;
  }

  Widget _buildCategoryPieChart(BuildContext context) {
    final categoryTotals = Provider.of<ExpenseProvider>(context, listen: true)
        .getExpensesByCategory();

    if (categoryTotals.isEmpty) {
      // Show nothing if there is no data
      return const SliverToBoxAdapter(
        child: SizedBox.shrink(),
      );
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expense Categories',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            CategoryPieChart(categoryTotals: categoryTotals),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyBarChart(BuildContext context) {
    // Access the ExpenseProvider and calculate the weekly data
    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: true);
    final weeklyData = _calculateWeeklyData(expenseProvider.expenses);

    // Check if there is enough data (at least one day with expenses)
    bool hasData = weeklyData.any((dayData) => dayData['total'] > 0);

    // Return an empty widget if there's no data
    if (!hasData) {
      return SliverToBoxAdapter(); // Empty widget, displays nothing
    }

    // If there is data, display the weekly bar chart
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Expenses',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8),
            WeeklyBarChart(weeklyData: weeklyData), // Pass the calculated data
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _calculateWeeklyData(List<Expense> expenses) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekDays =
        List.generate(7, (index) => weekStart.add(Duration(days: index)));

    return weekDays.map((day) {
      final dayExpenses = expenses.where((expense) =>
          expense.date.year == day.year &&
          expense.date.month == day.month &&
          expense.date.day == day.day);
      return {
        'day': DateFormat('EEE').format(day),
        'total': dayExpenses.fold(0.0, (sum, expense) => sum + expense.amount),
      };
    }).toList();
  }

  Widget _buildAddExpenseButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _navigateTo(context, const ExpenseLoggingScreen()),
      icon: const Icon(Icons.add),
      label: const Text('Add Expense'),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => screen));
  }
}
