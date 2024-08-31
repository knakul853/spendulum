import 'package:flutter/material.dart';

class AppConstants {
  static const Map<String, IconData> categoryIcons = {
    'housing': Icons.home,
    'utilities': Icons.flash_on,
    'food': Icons.fastfood,
    'transportation': Icons.directions_car,
    'healthcare': Icons.local_hospital,
    'entertainment': Icons.movie,
    'shopping': Icons.shopping_cart,
    'education': Icons.school,
    'savings': Icons.savings,
    'debt': Icons.credit_card,
  };

  static const Map<String, String> categoryColors = {
    'housing': 'FFB74D',
    'utilities': '4FC3F7',
    'food': '81C784',
    'transportation': 'FF8A65',
    'healthcare': 'E57373',
    'entertainment': 'BA68C8',
    'shopping': '64B5F6',
    'education': 'FFD54F',
    'savings': '4DB6AC',
    'debt': 'F06292',
  };
}
