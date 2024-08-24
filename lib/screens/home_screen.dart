import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budget_buddy/providers/expense_provider.dart';
import 'package:budget_buddy/screens/expense_logging_screen.dart';
import 'package:budget_buddy/screens/category_management_screen.dart';
import 'package:budget_buddy/widgets/expense_list_item.dart';
import 'package:budget_buddy/widgets/summary_card.dart';
import 'package:budget_buddy/widgets/action_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          _buildSummarySection(),
          _buildExpenseList(),
        ],
      ),
      floatingActionButton: _buildAddExpenseButton(context),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200.0,
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
