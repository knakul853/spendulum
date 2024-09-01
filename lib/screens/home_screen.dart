import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budget_buddy/providers/account_provider.dart';
import 'package:budget_buddy/screens/expense_logging_screen.dart';
import 'package:budget_buddy/screens/account_management_screen.dart';
import 'package:budget_buddy/widgets/account_cards/account_cards_list.dart';
import 'package:budget_buddy/widgets/expenses/expense_list.dart';
import 'package:budget_buddy/widgets/animated_background.dart';
import 'package:budget_buddy/widgets/month_selector.dart';
import 'package:budget_buddy/widgets/expenses/expense_summary_circle.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key}); // Changed to use 'super.key'

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedMonth = DateTime.now();

  void _onMonthChanged(DateTime newMonth) {
    setState(() {
      _selectedMonth = newMonth;
    });
    // Here you would typically update your data based on the new month
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountProvider>(
      builder: (context, accountProvider, _) {
        final selectedAccount = accountProvider.getSelectedAccount();

        if (selectedAccount == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                  builder: (context) => const AccountManagementScreen(
                        isInitialSetup: false,
                      )),
            );
          });
          return Container();
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
                        icon: const Icon(Icons.settings),
                        onPressed: () {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const AccountManagementScreen(),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                const begin =
                                    Offset(1.0, 0.0); // Start from the right
                                const end =
                                    Offset.zero; // End at the original position
                                const curve = Curves.easeInOut;

                                var tween = Tween(begin: begin, end: end)
                                    .chain(CurveTween(curve: curve));
                                var offsetAnimation = animation.drive(tween);

                                return SlideTransition(
                                  position: offsetAnimation,
                                  child: child,
                                );
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
                          width: 230, // Size of the circular background
                          height: 230, // Size of the circular background
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const RadialGradient(
                              colors: [
                                Color(
                                    0xFFF5F5F5), // Lighter color at the center
                                Color(0xFFE0E0E0), // Darker color at the edges
                              ],
                              stops: [0.5, 1.0], // Define the gradient spread
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4), // Shadow position
                              ),
                            ],
                          ),
                          child: Center(
                            child: ExpenseSummaryCircle(
                              selectedMonth: _selectedMonth,
                              accountId: selectedAccount.id,
                              currency: selectedAccount.currency,
                              size:
                                  230, // Size of the ExpenseSummaryCircle, adjust as needed
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // SliverToBoxAdapter(
                  //   child: MonthlyExpenseChart(
                  //     accountId: selectedAccount.id,
                  //     selectedMonth: _selectedMonth,
                  //   ),
                  // ),
                  // SliverToBoxAdapter(
                  //   child: CategoryPieChart(
                  //     accountId: selectedAccount.id,
                  //     selectedMonth: _selectedMonth,
                  //   ),
                  // ),
                  // SliverToBoxAdapter(
                  //   child: WeeklyBarChart(
                  //     accountId: selectedAccount.id,
                  //     selectedMonth: _selectedMonth,
                  //   ),
                  // ),
                  ExpenseList(
                    accountId: selectedAccount.id,
                    selectedMonth: _selectedMonth,
                  ),
                ],
              ),
              floatingActionButton:
                  _buildAddExpenseButton(context, selectedAccount.id),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAddExpenseButton(BuildContext context, String accountId) {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ExpenseLoggingScreen(initialAccountId: accountId),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0); // Start from the bottom
              const end = Offset.zero; // End at the original position
              const curve = Curves.easeInOut;

              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);

              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            },
          ),
        );
      },
      icon: const Icon(Icons.add),
      label: const Text('Add Expense'),
    );
  }
}
