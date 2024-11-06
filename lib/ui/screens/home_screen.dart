import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendulum/features/budget/screens/budget_screen.dart';
import 'package:spendulum/providers/account_provider.dart';
import 'package:spendulum/ui/screens/expense_logging_screen.dart';
import 'package:spendulum/ui/screens/income_logging_screen.dart';
import 'package:spendulum/ui/widgets/custom_button_tab.dart';
import 'package:spendulum/features/transactions/screens/transactions_screen.dart';
import 'package:spendulum/ui/screens/stats_screen.dart';
import 'package:spendulum/features/accounts/screens/account_management_screen.dart';
import 'package:spendulum/ui/widgets/logger.dart';
import 'package:spendulum/ui/screens/more_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override

  /// The main home screen of the application. It provides a bottom navigation
  /// bar and a page view with five screens: transactions, stats, budget,
  /// account management, and more.
  ///
  /// The transactions screen is responsible for displaying all the transactions
  /// for the selected account. The stats screen displays charts and summaries of
  /// the transactions. The budget screen allows the user to add, edit, and delete
  /// budgets. The account management screen allows the user to add, edit, and
  /// delete accounts. The more screen contains links to other features of the
  /// application.
  ///
  /// The floating action button is used to add new transactions.
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    AppLogger.info(
        "The scaffold background color is: ${theme.scaffoldBackgroundColor}");
    return Consumer<AccountProvider>(
      builder: (context, accountProvider, _) {
        final selectedAccount = accountProvider.getSelectedAccount();
        if (selectedAccount == null) {
          return _buildLoadingScreen();
        }

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: PageView(
            controller: _pageController,
            physics: NeverScrollableScrollPhysics(),
            onPageChanged: (index) => setState(() => _currentIndex = index),
            children: [
              TransactionsScreen(selectedAccount: selectedAccount),
              StatsScreen(selectedAccount: selectedAccount),
              BudgetScreen(),
              AccountManagementScreen(
                isInitialSetup: false,
              ),
              MoreScreen(),
            ],
          ),
          bottomNavigationBar: AnimatedBottomNav(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() => _currentIndex = index);
              _pageController.jumpToPage(
                index,
              );
            },
            selectedAccount: selectedAccount,
          ),
          floatingActionButton: _currentIndex == 0
              ? _buildAddButton(context, selectedAccount.id)
              : null,
        );
      },
    );
  }

  /// A temporary screen that is displayed while the application is waiting for
  /// the selected account to be loaded.
  ///
  /// The screen displays a centered [CircularProgressIndicator] with the text
  /// "Loading account..." below it.
  ///
  /// This screen is only displayed when the selected account is not available.
  Widget _buildLoadingScreen() {
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
