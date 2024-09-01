import 'package:flutter/material.dart';
import 'package:spendulum/models/category.dart';
import 'package:spendulum/utils/category_utils.dart';

class CategoryProvider with ChangeNotifier {
  final List<Category> _categories = [
    CategoryUtils.createCategory('Housing'),
    CategoryUtils.createCategory('Utilities'),
    CategoryUtils.createCategory('Food'),
    CategoryUtils.createCategory('Transportation'),
    CategoryUtils.createCategory('Healthcare'),
    CategoryUtils.createCategory('Entertainment'),
    CategoryUtils.createCategory('Shopping'),
    CategoryUtils.createCategory('Education'),
    CategoryUtils.createCategory('Savings'),
    CategoryUtils.createCategory('Debt'),
    CategoryUtils.createCategory('Other'),
  ];

  List<Category> get categories => _categories;

  // Add a new category
  void addCategory(String name) {
    final newCategory = CategoryUtils.createCategory(name);
    _categories.add(newCategory);
    notifyListeners();
    debugPrint('Category added: $newCategory');
  }

  // Remove a category by ID
  void removeCategory(String id) {
    _categories.removeWhere((category) => category.id == id);
    notifyListeners();
    debugPrint('Category removed: $id');
  }
}
