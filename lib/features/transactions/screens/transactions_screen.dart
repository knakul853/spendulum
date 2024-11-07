import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendulum/models/account.dart';
import 'package:spendulum/providers/expense_provider.dart';
import 'package:spendulum/providers/income_provider.dart';
import 'package:spendulum/ui/widgets/month_selector.dart';
import 'package:spendulum/ui/widgets/logger.dart';
import 'package:spendulum/features/accounts/widgets/account_cards_list.dart';
import 'package:spendulum/features/expenses/widgets/expense_income_list.dart';

class TransactionsScreen extends StatefulWidget {
  final Account selectedAccount;

  const TransactionsScreen({Key? key, required this.selectedAccount})
      : super(key: key);

  @override
  _TransactionsScreenState createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  DateTime _selectedMonth =
      DateTime(DateTime.now().year, DateTime.now().month, 1);

  @override
  void initState() {
    super.initState();
    AppLogger.info("TransactionsScreen: initState called");
    _loadData();
  }

  void _onMonthChanged(DateTime newMonth) {
    setState(() {
      _selectedMonth = newMonth;
    });
    _loadData();
  }

  void _loadData() {
    AppLogger.info(
        "Loading data for account: ${widget.selectedAccount.accountNumber}");
    final expenseProvider =
        Provider.of<ExpenseProvider>(context, listen: false);
    expenseProvider.loadExpenses(widget.selectedAccount.id, _selectedMonth);

    final incomeProvider = Provider.of<IncomeProvider>(context, listen: false);
    incomeProvider.loadIncomes(widget.selectedAccount.id, _selectedMonth);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get the current theme

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          expandedHeight: 160.0,
          floating: false,
          pinned: true,
          automaticallyImplyLeading: false,
          flexibleSpace: FlexibleSpaceBar(
            background: Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: AccountCardsList(),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: MonthSelector(
              selectedMonth: _selectedMonth,
              onMonthChanged: _onMonthChanged,
            ),
          ),
        ),
        SliverFillRemaining(
          child: ExpenseIncomeList(
            accountId: widget.selectedAccount.id,
            selectedMonth: _selectedMonth,
          ),
        ),
      ],
    );
  }
}
