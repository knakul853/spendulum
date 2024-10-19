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
    return Container(
      padding: EdgeInsets.all(0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Material(
          color: Color.fromARGB(255, 57, 30, 63),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.list, 'Transactions', 0),
                _buildNavItem(Icons.bar_chart, 'Stats', 1),
                _buildNavItem(Icons.account_balance_wallet, 'Accounts', 2),
                _buildNavItem(Icons.more_horiz, 'More', 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 26),
        decoration: BoxDecoration(
          color: currentIndex == index
              ? Color.fromARGB(80, 238, 184, 237)
              : Colors.transparent,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15), // Adjust as needed
            topRight: Radius.circular(15), // Adjust as needed
            bottomLeft: Radius.circular(0), // No curve for bottom left
            bottomRight: Radius.circular(0), // No curve for bottom right
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
                color: currentIndex == index ? Colors.white : Colors.white70,
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: currentIndex == index ? Colors.white : Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
