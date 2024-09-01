import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendulum/providers/expense_provider.dart';
import 'package:vector_math/vector_math.dart' as vector;
import 'package:spendulum/providers/account_provider.dart';

class ExpenseSummaryCircle extends StatefulWidget {
  final DateTime selectedMonth;
  final String accountId;
  final double size;
  final String currency; // Add currency parameter

  const ExpenseSummaryCircle({
    Key? key,
    required this.selectedMonth,
    required this.accountId,
    this.size = 140,
    required this.currency, // Update constructor
  }) : super(key: key);

  @override
  _ExpenseSummaryCircleState createState() => _ExpenseSummaryCircleState();
}

class _ExpenseSummaryCircleState extends State<ExpenseSummaryCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ExpenseProvider, AccountProvider>(
      builder: (context, expenseProvider, accountProvider, _) {
        final totalExpenses = expenseProvider.getTotalExpensesForMonth(
          widget.selectedMonth,
          accountId: widget.accountId,
        );
        final account = accountProvider.accounts.firstWhere(
          (account) => account.id == widget.accountId,
          orElse: () => throw Exception('Account not found'),
        );

        final balance = account.balance;

        final progress = (totalExpenses / balance).clamp(0.0, 1.0);

        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return SizedBox(
              height: widget.size,
              width: widget.size,
              child: CustomPaint(
                painter: CircleProgressPainter(
                  progress: _animation.value * progress,
                  color: Theme.of(context).primaryColor,
                  strokeWidth: widget.size * 0.15,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Amount Paid',
                        style: TextStyle(fontSize: widget.size * 0.05),
                      ),
                      SizedBox(height: widget.size * 0.02),
                      Text(
                        '${_getCurrencySymbol(widget.currency)}${(totalExpenses * _animation.value).toStringAsFixed(0)}', // Use currency symbol
                        style: TextStyle(
                          fontSize: widget.size * 0.1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: widget.size * 0.02),
                      Text(
                        'of ${_getCurrencySymbol(widget.currency)}${balance.toStringAsFixed(0)}', // Use currency symbol
                        style: TextStyle(fontSize: widget.size * 0.05),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
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
        return '\$'; // Default to USD
    }
  }
}

class CircleProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  CircleProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final paint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, paint);

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      vector.radians(-90),
      vector.radians(360 * progress),
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
