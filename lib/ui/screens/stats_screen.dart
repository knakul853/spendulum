import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendulum/models/account.dart';
import 'package:spendulum/providers/expense_provider.dart';
import 'package:spendulum/ui/widgets/charts/category_expense_chart.dart';
import 'package:spendulum/ui/widgets/expenses/expense_summary_circle.dart';
import 'package:spendulum/ui/widgets/monthly_expense_chart.dart'; // Import the new widget

class StatsScreen extends StatefulWidget {
  final Account selectedAccount;

  const StatsScreen({Key? key, required this.selectedAccount})
      : super(key: key);

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  late ExpenseProvider expenseProvider;
  DateTime startDate =
      DateTime(DateTime.now().year, 1, 1); // Start of the current year
  DateTime endDate = DateTime.now(); // Current date

  @override
  void initState() {
    super.initState();
    expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(58, 109, 140, 0.5), // Adjusted opacity
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 80.0, // Reduced expanded height
            floating: false,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor:
                Theme.of(context).primaryColor, //Use primary color for appbar
            flexibleSpace: FlexibleSpaceBar(
              background: Container(),
            ),
            title: const Text('Statistics', style: TextStyle(color: Colors.white)),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 230,
                  height: 230,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context)
                          .primaryColor, //Consistent background color
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
                        selectedMonth: DateTime.now(),
                        accountId: widget.selectedAccount.id,
                        currency: '\$',
                        size: 230,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: CategoryExpenseChart(
                    selectedAccount: widget.selectedAccount,
                  ),
                )),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  children: [
                    Text(
                      'Expense Trend',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    EnhancedExpenseTrendChart(
                      selectedAccountId: widget.selectedAccount.id,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
