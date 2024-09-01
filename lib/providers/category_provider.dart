import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:spendulum/models/category.dart';
import 'package:spendulum/services/database/database_helper.dart';
import 'package:spendulum/ui/widgets/logger.dart';
import 'package:spendulum/utils/category_utils.dart';
import 'package:spendulum/services/database/tables/category_table.dart';

class CategoryProvider with ChangeNotifier {
  List<Category> _categories = [];

  List<Category> get categories => _categories;

  // Load categories from the database
  Future<void> loadCategories() async {
    AppLogger.info('Loading categories');
    try {
      final categoryMaps =
          await DatabaseHelper.instance.queryAllRows(CategoriesTable.tableName);

      if (categoryMaps.isEmpty) {
        await _createDefaultCategories();
      } else {
        _categories = categoryMaps
            .map((map) => Category(
                  id: map[CategoriesTable.columnId] as String,
                  name: map[CategoriesTable.columnName] as String,
                  color: map[CategoriesTable.columnColor] as String,
                  icon: IconData(map[CategoriesTable.columnIcon] as int,
                      fontFamily: 'MaterialIcons'),
                ))
            .toList();
      }

      AppLogger.info('Loaded ${_categories.length} categories');
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error loading categories', error: e);
    }
  }

  // Create default categories
  Future<void> _createDefaultCategories() async {
    AppLogger.info('Creating default categories');
    final defaultCategories = [
      'Housing',
      'Utilities',
      'Food',
      'Transportation',
      'Healthcare',
      'Entertainment',
      'Shopping',
      'Education',
      'Savings',
      'Debt',
      'Other',
    ];

    for (final categoryName in defaultCategories) {
      final category = CategoryUtils.createCategory(categoryName);
      await _addCategoryToDatabase(category);
      _categories.add(category);
    }
    AppLogger.info('Default categories created');
  }

  // Add a category to the database
  Future<void> _addCategoryToDatabase(Category category) async {
    await DatabaseHelper.instance.insert(CategoriesTable.tableName, {
      CategoriesTable.columnId: category.id,
      CategoriesTable.columnName: category.name,
      CategoriesTable.columnColor: category.color,
      CategoriesTable.columnIcon: category.icon.codePoint,
    });
  }

  // Add a new custom category
  Future<void> addCategory(String name, String color, IconData icon) async {
    AppLogger.info('Adding new category: $name');
    try {
      final newCategory = Category(
        id: const Uuid().v4(),
        name: name,
        color: color,
        icon: icon,
      );

      await _addCategoryToDatabase(newCategory);

      _categories.add(newCategory);
      notifyListeners();
      AppLogger.info('Category added successfully: ${newCategory.id}');
    } catch (e) {
      AppLogger.error('Error adding category', error: e);
    }
  }

  // Remove a category by ID
  Future<void> removeCategory(String id) async {
    AppLogger.info('Removing category: $id');
    try {
      // Remove from database
      await DatabaseHelper.instance.delete(
        CategoriesTable.tableName,
        CategoriesTable.columnId,
        id,
      );

      _categories.removeWhere((category) => category.id == id);
      notifyListeners();
      AppLogger.info('Category removed successfully: $id');
    } catch (e) {
      AppLogger.error('Error removing category', error: e);
    }
  }

  // Update a category
  Future<void> updateCategory(
      String id, String name, String color, IconData icon) async {
    AppLogger.info('Updating category: $id');
    try {
      final updatedCategory = Category(
        id: id,
        name: name,
        color: color,
        icon: icon,
      );

      // Update in database
      await DatabaseHelper.instance.update(
        CategoriesTable.tableName,
        {
          CategoriesTable.columnName: updatedCategory.name,
          CategoriesTable.columnColor: updatedCategory.color,
          CategoriesTable.columnIcon: updatedCategory.icon.codePoint,
        },
        CategoriesTable.columnId,
        id,
      );

      final index = _categories.indexWhere((category) => category.id == id);
      if (index != -1) {
        _categories[index] = updatedCategory;
        notifyListeners();
      }
      AppLogger.info('Category updated successfully: $id');
    } catch (e) {
      AppLogger.error('Error updating category', error: e);
    }
  }

  // Get a category by ID
  Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      AppLogger.warn('Category not found: $id');
      return null;
    }
  }
}
