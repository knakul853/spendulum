import 'package:flutter/material.dart';
import 'package:spendulum/constants/app_colors.dart'; // Import AppColors

class ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const ActionButton({
    Key? key,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: AppColors.text), // Use AppColors.text for icon color
      onPressed: onPressed,
    );
  }
}
