import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendulum/providers/account_provider.dart';
import 'package:spendulum/ui/screens/expense_logging_screen.dart';
import 'package:spendulum/ui/screens/income_logging_screen.dart';
import 'package:spendulum/ui/screens/account_management_screen.dart';
import 'package:spendulum/ui/widgets/account_cards/account_cards_list.dart';
import 'package:spendulum/ui/widgets/animated_background.dart';
import 'package:spendulum/ui/widgets/month_selector.dart';
import 'package:spendulum/ui/widgets/expenses/expense_summary_circle.dart';
import 'package:spendulum/ui/widgets/logger.dart';
import 'package:spendulum/providers/expense_provider.dart';
import 'package:spendulum/providers/income_provider.dart';
import 'package:spendulum/models/account.dart';
import 'package:spendulum/ui/widgets/expenses/expense_income_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedMonth =
      DateTime(DateTime.now().year, DateTime.now().month, 1);
  Account? selectedAccount;

  @override
  void initState() {
    super.initState();
    AppLogger.info("HomeScreen: initState called");
    final accountProvider =
        Provider.of<AccountProvider>(context, listen: false);
    selectedAccount = accountProvider.getSelectedAccount();

    if (selectedAccount != null) {
      final expenseProvider =
          Provider.of<ExpenseProvider>(context, listen: false);
      expenseProvider.loadExpenses(selectedAccount!.id, _selectedMonth);

      final incomeProvider =
          Provider.of<IncomeProvider>(context, listen: false);
      incomeProvider.loadIncomes(selectedAccount!.id, _selectedMonth);
    }
  }

  void _onMonthChanged(DateTime newMonth) {
    setState(() {
      _selectedMonth = newMonth;
    });
    _loadData();
  }

  void _loadData() {
    if (selectedAccount != null) {
      AppLogger.info(
          "Loading data for account: ${selectedAccount?.accountNumber}");
      final expenseProvider =
          Provider.of<ExpenseProvider>(context, listen: false);
      expenseProvider.loadExpenses(selectedAccount!.id, _selectedMonth);

      final incomeProvider =
          Provider.of<IncomeProvider>(context, listen: false);
      incomeProvider.loadIncomes(selectedAccount!.id, _selectedMonth);
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.info("HomeScreen: build method called");

    return Consumer<AccountProvider>(
      builder: (context, accountProvider, _) {
        selectedAccount = accountProvider.getSelectedAccount();
        AppLogger.info(
            "The selected account is: ${selectedAccount?.accountNumber}");

        _loadData();

        if (selectedAccount == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Loading account...'),
                ],
              ),
            ),
          );
        }

        return Stack(
          children: [
            AnimatedBackground(color: Theme.of(context).primaryColor),
            Scaffold(
              backgroundColor: Colors.transparent,
              body: CustomScrollView(
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
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const AccountManagementScreen(
                                          isInitialSetup: false),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
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
                    flexibleSpace: const FlexibleSpaceBar(
                      background: Padding(
                        padding: EdgeInsets.only(top: 60.0),
                        child: AccountCardsList(),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: MonthSelector(
                        selectedMonth: _selectedMonth,
                        onMonthChanged: _onMonthChanged,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      child: Center(
                        child: Container(
                          width: 230,
                          height: 230,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const RadialGradient(
                              colors: [Color(0xFFF5F5F5), Color(0xFFE0E0E0)],
                              stops: [0.5, 1.0],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: ExpenseSummaryCircle(
                              selectedMonth: _selectedMonth,
                              accountId: selectedAccount!.id,
                              currency: selectedAccount!.currency,
                              size: 230,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverFillRemaining(
                    child: ExpenseIncomeList(
                      accountId: selectedAccount!.id,
                      selectedMonth: _selectedMonth,
                    ),
                  ),
                ],
              ),
              floatingActionButton:
                  _buildAddButton(context, selectedAccount!.id),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAddButton(BuildContext context, String accountId) {
    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Container(
              height: 120,
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.remove_circle_outline),
                    title: Text('Add Expense'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (context, animation,
                                  secondaryAnimation) =>
                              ExpenseLoggingScreen(initialAccountId: accountId),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            const begin = Offset(0.0, 1.0);
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
                  ListTile(
                    leading: Icon(Icons.add_circle_outline),
                    title: Text('Add Income'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (context, animation,
                                  secondaryAnimation) =>
                              IncomeLoggingScreen(initialAccountId: accountId),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            const begin = Offset(0.0, 1.0);
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
              ),
            );
          },
        );
      },
      child: Icon(Icons.add),
    );
  }
}
