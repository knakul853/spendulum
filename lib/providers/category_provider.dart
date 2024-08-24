import 'package:flutter/material.dart';
import 'package:budget_buddy/models/category.dart';
import 'package:uuid/uuid.dart';

class CategoryProvider with ChangeNotifier {
  final List<Category> _categories = [
    Category(
      id: const Uuid().v4(),
      name: 'Housing',
      color: 'FFB74D',
      icon: Icons.home, // Example icon
    ),
    Category(
      id: const Uuid().v4(),
      name: 'Utilities',
      color: '4FC3F7',
      icon: Icons.flash_on, // Example icon
    ),
    Category(
      id: const Uuid().v4(),
      name: 'Food',
      color: '81C784',
      icon: Icons.fastfood, // Example icon
    ),
    Category(
      id: const Uuid().v4(),
      name: 'Transportation',
      color: 'FF8A65',
      icon: Icons.directions_car, // Example icon
    ),
    // Add more categories as needed
  ];

  List<Category> get categories => _categories;

  // Add a new category
  void addCategory(String name, String color, IconData iconData) {
    final newCategory = Category(
        id: const Uuid().v4(), // Generate a unique ID for each category
        name: name,
        color: color,
        icon: iconData);
    _categories.add(newCategory);
    notifyListeners(); // Notify listeners about the state change
    debugPrint('Category added: $newCategory');
  }

  // Remove a category by ID
  void removeCategory(String id) {
    _categories.removeWhere((category) => category.id == id);
    notifyListeners();
    debugPrint('Category removed: $id');
  }
}
