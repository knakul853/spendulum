import 'package:flutter/material.dart';
import 'package:spendulum/models/expense.dart';
import 'package:intl/intl.dart';
import 'package:spendulum/constants/app_constants.dart';
import 'package:spendulum/utils/currency.dart';

class ExpenseListItem extends StatefulWidget {
  final Expense expense;
  final String currency; // Add currency parameter

  const ExpenseListItem(
      {Key? key, required this.expense, required this.currency})
      : super(key: key);

  @override
  _ExpenseListItemState createState() => _ExpenseListItemState();
}

class _ExpenseListItemState extends State<ExpenseListItem>
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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateTimeFormat = DateFormat("MMM d, yyyy 'at' h:mm a");
    final formattedDateTime = dateTimeFormat.format(widget.expense.date);
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
                widget.expense.category,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.expense.description.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 4, bottom: 8),
                      child: Text(
                        widget.expense.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                  Text(
                    formattedDateTime,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: 4),
                  Text(
                    '${getCurrencySymbol(widget.currency)}${NumberFormat('#,##0.00').format(widget.expense.amount)}', // Format amount
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
              leading: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getCategoryColor(widget.expense.category),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.surface.withOpacity(0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  _getCategoryIcon(widget.expense.category),
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

  IconData _getCategoryIcon(String category) {
    final lowercaseCategory = category.toLowerCase();
    return AppConstants.categoryIcons[lowercaseCategory] ??
        Icons.category; // Default icon
  }

  Color _getCategoryColor(String category) {
    final lowercaseCategory = category.toLowerCase();
    return Color(int.parse(
        '0xff${AppConstants.categoryColors[lowercaseCategory] ?? 'CCCCCC'}'));
  }
}
