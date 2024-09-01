import 'package:flutter/material.dart';
import 'package:budget_buddy/models/account.dart';
import 'package:budget_buddy/widgets/animated_card_shape.dart';
import 'package:intl/intl.dart';

class AccountCard extends StatelessWidget {
  final Account account;
  final bool isSelected;
  final VoidCallback onTap;

  const AccountCard({
    Key? key,
    required this.account,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print('Account card tapped: ${account.name}');
        onTap(); // Log statement
      },
      child: Container(
        width: 160,
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? account.color : account.color.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? Colors.black.withOpacity(0.2)
                  : Colors.black.withOpacity(0.1),
              blurRadius: isSelected ? 12 : 8,
              offset: Offset(0, isSelected ? 6 : 4),
            ),
          ],
          border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedCardShape(),
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      account.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: isSelected ? 16 : 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Balance',
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: isSelected ? 12 : 10),
                        ),
                        isSelected
                            ? Text(
                                '${_getCurrencySymbol(account.currency)}${NumberFormat('#,##0').format(account.balance)}', // Use currency symbol
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              )
                            : const Text(
                                '• • • •',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  letterSpacing: 2,
                                ),
                              ),
                        Text(
                          account.accountType,
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: isSelected ? 12 : 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (isSelected)
              const Positioned(
                bottom: 8,
                right: 8,
                child: Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
