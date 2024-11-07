import 'package:flutter/material.dart';
import 'package:spendulum/models/account.dart';

class AnimatedBottomNav extends StatelessWidget {
  final int currentIndex;
  final Account selectedAccount;
  final Function(int) onTap;

  AnimatedBottomNav(
      {required this.currentIndex,
      required this.onTap,
      required this.selectedAccount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Material(
          color: theme.colorScheme.secondary,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.list, 'Transactions', 0, context),
                _buildNavItem(Icons.bar_chart, 'Stats', 1, context),
                _buildNavItem(Icons.account_balance, 'Budget', 2, context),
                _buildNavItem(Icons.account_balance_wallet_outlined, 'Account',
                    3, context),
                _buildNavItem(Icons.more_horiz, 'More', 4, context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      IconData icon, String label, int index, BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: currentIndex == index
              ? theme.colorScheme.primary.withOpacity(0.4)
              : Colors.transparent,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
            bottomLeft: Radius.circular(0),
            bottomRight: Radius.circular(0),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              transform: Matrix4.identity()
                ..scale(currentIndex == index ? 1.2 : 1.0)
                ..translate(currentIndex == index ? 2.0 : 0.0),
              child: Icon(
                icon,
                color: currentIndex == index
                    ? theme.textTheme.bodyMedium?.color
                    : theme.textTheme.bodySmall?.color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: currentIndex == index
                    ? theme.textTheme.bodyMedium?.color
                    : theme.textTheme.bodySmall?.color,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
