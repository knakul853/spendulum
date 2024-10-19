import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendulum/models/account.dart';
import 'package:spendulum/providers/expense_provider.dart';
import 'package:spendulum/providers/income_provider.dart';
import 'package:spendulum/ui/widgets/month_selector.dart';
import 'package:spendulum/ui/widgets/logger.dart';
import 'package:spendulum/features/accounts/screens/account_management_screen.dart';
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
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 160.0,
          floating: false,
          pinned: true,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const AccountManagementScreen(isInitialSetup: false),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.easeInOut;
                      var tween = Tween(begin: begin, end: end)
                          .chain(CurveTween(curve: curve));
                      var offsetAnimation = animation.drive(tween);
                      return SlideTransition(
                          position: offsetAnimation, child: child);
                    },
                  ),
                );
              },
            ),
          ],
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
