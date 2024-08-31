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
  const HomeScreen({Key? key}) : super(key: key);

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
                  builder: (context) => AccountManagementScreen()),
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
                  const SliverAppBar(
                    expandedHeight: 160.0,
                    floating: false,
                    pinned: true,
                    automaticallyImplyLeading: false,
                    backgroundColor: Colors.transparent,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Padding(
                        padding: EdgeInsets.only(top: 40.0),
                        child: AccountCardsList(),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: MonthSelector(
                        selectedMonth: _selectedMonth,
                        onMonthChanged: _onMonthChanged,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                                offset: Offset(0, 4), // Shadow position
                              ),
                            ],
                          ),
                          child: Center(
                            child: ExpenseSummaryCircle(
                              selectedMonth: _selectedMonth,
                              accountId: selectedAccount.id,
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
      onPressed: () => _navigateTo(
          context, ExpenseLoggingScreen(initialAccountId: accountId)),
      icon: const Icon(Icons.add),
      label: const Text('Add Expense'),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => screen));
  }
}
