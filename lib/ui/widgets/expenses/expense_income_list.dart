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

        return _buildList(
          items: expenses,
          itemBuilder: (expense) =>
              ExpenseListItem(expense: expense, currency: accountCurrency),
          emptyMessage: 'No Expenses Found',
          title: '${DateFormat.MMMM().format(widget.selectedMonth)} Expenses',
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

        return _buildList(
          items: incomes,
          itemBuilder: (income) =>
              IncomeListItem(income: income, currency: accountCurrency),
          emptyMessage: 'No Income Found',
          title: '${DateFormat.MMMM().format(widget.selectedMonth)} Income',
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
    return CustomScrollView(
      slivers: [
        items.isEmpty
            ? SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    emptyMessage,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 1.5,
                        ),
                  ),
                ),
              )
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => itemBuilder(items[index]),
                  childCount: items.length,
                ),
              ),
        SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }
}
