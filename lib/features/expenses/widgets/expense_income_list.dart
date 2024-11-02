import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendulum/providers/expense_provider.dart';
import 'package:spendulum/providers/income_provider.dart';
import 'package:spendulum/ui/widgets/expense_list_item.dart';
import 'package:spendulum/ui/widgets/income_list_item.dart';
import 'package:spendulum/providers/account_provider.dart';
import 'package:intl/intl.dart';
import 'package:spendulum/ui/widgets/logger.dart';
import 'package:spendulum/ui/widgets/tabBar.dart';

class ExpenseIncomeList extends StatefulWidget {
  final String accountId;
  final DateTime selectedMonth;

  const ExpenseIncomeList({
    Key? key,
    required this.accountId,
    required this.selectedMonth,
  }) : super(key: key);

  @override
  _ExpenseIncomeListState createState() => _ExpenseIncomeListState();
}

class _ExpenseIncomeListState extends State<ExpenseIncomeList>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    AppLogger.info('ExpenseIncomeList: Initialized with TabController');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
    AppLogger.info('ExpenseIncomeList: Disposed TabController');
  }

  String _getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'INR':
        return '₹';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      default:
        return '\$';
    }
  }

  Widget _buildTotalCard(double total, String currency, String title) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total $title',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          Text(
            '${_getCurrencySymbol(currency)}${NumberFormat('#,##0.00').format(total)}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.info('ExpenseIncomeList: Building widget');
    return Column(
      children: [
        StyledTabBar(controller: _tabController),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildExpenseList(),
              _buildIncomeList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseList() {
    AppLogger.info('ExpenseIncomeList: Building expense list');
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, _) {
        final expenses = expenseProvider.getExpensesForMonth(
            widget.selectedMonth,
            accountId: widget.accountId);
        final accountProvider = Provider.of<AccountProvider>(context);
        final accountCurrency =
            accountProvider.getCurrencyCode(widget.accountId);

        // Calculate total expenses
        final totalExpenses = expenses.fold<double>(
          0,
          (sum, expense) => sum + expense.amount,
        );

        return Column(
          children: [
            _buildTotalCard(totalExpenses, accountCurrency, 'Expenses'),
            Expanded(
              child: _buildList(
                items: expenses,
                itemBuilder: (expense) => ExpenseListItem(
                    expense: expense, currency: accountCurrency),
                emptyMessage: 'No Expenses Found',
                title:
                    '${DateFormat.MMMM().format(widget.selectedMonth)} Expenses',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIncomeList() {
    AppLogger.info('ExpenseIncomeList: Building income list');
    return Consumer<IncomeProvider>(
      builder: (context, incomeProvider, _) {
        final incomes = incomeProvider.getIncomesForMonth(widget.selectedMonth,
            accountId: widget.accountId);
        final accountProvider = Provider.of<AccountProvider>(context);
        final accountCurrency =
            accountProvider.getCurrencyCode(widget.accountId);

        // Calculate total income
        final totalIncome = incomes.fold<double>(
          0,
          (sum, income) => sum + income.amount,
        );

        return Column(
          children: [
            _buildTotalCard(totalIncome, accountCurrency, 'Income'),
            Expanded(
              child: _buildList(
                items: incomes,
                itemBuilder: (income) =>
                    IncomeListItem(income: income, currency: accountCurrency),
                emptyMessage: 'No Income Found',
                title:
                    '${DateFormat.MMMM().format(widget.selectedMonth)} Income',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildList({
    required List<dynamic> items,
    required Widget Function(dynamic) itemBuilder,
    required String emptyMessage,
    required String title,
  }) {
    return Container(
      child: items.isEmpty
          ? Center(
              child: Text(
                emptyMessage,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1.5,
                    ),
              ),
            )
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) => itemBuilder(items[index]),
            ),
    );
  }
}
