import 'package:flutter/material.dart';
import 'package:spendulum/models/income.dart';
import 'package:intl/intl.dart';
import 'package:spendulum/ui/widgets/logger.dart';

class IncomeListItem extends StatefulWidget {
  final Income income;
  final String currency;

  const IncomeListItem({Key? key, required this.income, required this.currency})
      : super(key: key);

  @override
  _IncomeListItemState createState() => _IncomeListItemState();
}

class _IncomeListItemState extends State<IncomeListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    AppLogger.info('IncomeListItem: Initialized with animation controller');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
    AppLogger.info('IncomeListItem: Disposed animation controller');
  }

  @override
  Widget build(BuildContext context) {
    final dateTimeFormat = DateFormat("MMM d, yyyy 'at' h:mm a");
    final formattedDateTime = dateTimeFormat.format(widget.income.date);
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        child: Card(
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          elevation: 8,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.primaryColor,
                  theme.primaryColor.withOpacity(0.7)
                ],
              ),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.fromLTRB(16, 0, 16, 0),
              title: Text(
                widget.income.source,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.income.description.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 4, bottom: 8),
                      child: Text(
                        widget.income.description,
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  Text(
                    formattedDateTime,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
              trailing: Text(
                '${_getCurrencySymbol(widget.currency)}${NumberFormat('#,##0.00').format(widget.income.amount)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.green,
                ),
              ),
              leading: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.attach_money,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ),
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
        return '\$';
    }
  }
}
