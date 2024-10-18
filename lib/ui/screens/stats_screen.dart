import 'package:flutter/material.dart';
import 'package:spendulum/models/account.dart';
import 'package:spendulum/ui/widgets/expenses/expense_summary_circle.dart';
import 'package:spendulum/ui/widgets/animated_background.dart';

class StatsScreen extends StatelessWidget {
  final Account selectedAccount;

  const StatsScreen({Key? key, required this.selectedAccount})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                backgroundColor: Colors.transparent, // Removed background color
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(),
                ),
                title: Stack(
                  // Added Stack for title
                  children: [
                    const Text('Statistics'),
                    AnimatedBackground(color: Theme.of(context).primaryColor),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                          selectedMonth: DateTime.now(),
                          accountId: selectedAccount.id,
                          currency: '\$',
                          size: 230,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
