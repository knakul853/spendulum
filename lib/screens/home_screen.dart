import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budget_buddy/providers/expense_provider.dart';
import 'package:budget_buddy/providers/account_provider.dart';
import 'package:budget_buddy/screens/expense_logging_screen.dart';
import 'package:budget_buddy/screens/category_management_screen.dart';
import 'package:budget_buddy/widgets/expense_list_item.dart';
import 'package:budget_buddy/widgets/summary_card.dart';
import 'package:budget_buddy/widgets/action_button.dart';
import 'package:budget_buddy/screens/expense_chart.dart';
import 'package:budget_buddy/screens/category_pie_chart.dart';
import 'package:budget_buddy/screens/weekly_bar_chart.dart';
import 'package:budget_buddy/screens/account_management_screen.dart';
import 'package:budget_buddy/models/expense.dart';
import 'package:intl/intl.dart';
import 'package:budget_buddy/models/account.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountProvider>(
      builder: (context, accountProvider, _) {
        final selectedAccount = accountProvider.getSelectedAccount();

        if (selectedAccount == null) {
          // If there's no account, navigate to AccountManagementScreen
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                  builder: (context) => AccountManagementScreen()),
            );
          });
          return Container(); // Return an empty container while navigating
        }
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              _buildAppBar(context, accountProvider),
              _buildMonthlyExpenseChart(context, selectedAccount.id),
              _buildCategoryPieChart(context, selectedAccount.id),
              _buildWeeklyBarChart(context, selectedAccount.id),
              _buildSummarySection(selectedAccount.id),
              _buildExpenseList(selectedAccount.id),
            ],
          ),
          floatingActionButton:
              _buildAddExpenseButton(context, selectedAccount.id),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, AccountProvider accountProvider) {
    return SliverAppBar(
      expandedHeight: 110.0,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Container(
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
            Positioned(
              top: 40.0,
              left: 16.0,
              child: Text(
                'Budget Buddy',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: _buildAccountTabs(context, accountProvider),
      ),
      // actions: [
      //   IconButton(
      //     icon: Icon(Icons.settings),
      //     onPressed: () =>
      //         _navigateTo(context, const AccountManagementScreen()),
      //   ),
      // ],
    );
  }

  Widget _buildAccountTabs(
      BuildContext context, AccountProvider accountProvider) {
    return Container(
      height: 60,
      child: Row(
        children: [
          Expanded(
            child: accountProvider.accounts.isEmpty
                ? Center(child: Text('No accounts added'))
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: accountProvider.accounts.length + 1,
                    itemBuilder: (context, index) {
                      if (index == accountProvider.accounts.length) {
                        return _buildAddAccountButton(context);
                      }
                      final account = accountProvider.accounts[index];
                      return _buildAccountTab(
                          context, account, accountProvider);
                    },
                  ),
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () =>
                _navigateTo(context, const AccountManagementScreen()),
          ),
        ],
      ),
    );
  }

  /**
   * 
   */

  Widget _buildAccountTab(
      BuildContext context, Account account, AccountProvider accountProvider) {
    final isSelected = account.id == accountProvider.selectedAccountId;
    return GestureDetector(
      onTap: () => accountProvider.selectAccount(account.id),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? account.color : account.color.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          account.name,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildAddAccountButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateTo(context, const AccountManagementScreen()),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: Colors.white, size: 18),
            SizedBox(width: 4),
            Text('Add Account', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  // Update other methods to accept accountId parameter
  Widget _buildSummarySection(String accountId) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<ExpenseProvider>(
          builder: (context, expenseProvider, child) {
            final totalExpenses =
                expenseProvider.getTotalExpenses(accountId: accountId);
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

  Widget _buildExpenseList(String accountId) {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, child) {
        final expenses = expenseProvider.expenses
            .where((e) => e.accountId == accountId)
            .toList();
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

  Widget _buildMonthlyExpenseChart(BuildContext context, String accountId) {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, child) {
        final monthlyData = _calculateMonthlyData(expenseProvider.expenses
            .where((e) => e.accountId == accountId)
            .toList());

        if (monthlyData.length < 2) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

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

  Widget _buildCategoryPieChart(BuildContext context, String accountId) {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, child) {
        final categoryTotals =
            expenseProvider.getExpensesByCategory(accountId: accountId);

        if (categoryTotals.isEmpty) {
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
      },
    );
  }

  Widget _buildWeeklyBarChart(BuildContext context, String accountId) {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, child) {
        final weeklyData = _calculateWeeklyData(expenseProvider.expenses
            .where((e) => e.accountId == accountId)
            .toList());

        bool hasData = weeklyData.any((dayData) => dayData['total'] > 0);

        if (!hasData) {
          return SliverToBoxAdapter();
        }

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
                WeeklyBarChart(weeklyData: weeklyData),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddExpenseButton(BuildContext context, String accountId) {
    return FloatingActionButton.extended(
      onPressed: () => _navigateTo(
          context, ExpenseLoggingScreen(initialAccountId: accountId)),
      icon: const Icon(Icons.add),
      label: const Text('Add Expense'),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => screen));
  }

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
}
