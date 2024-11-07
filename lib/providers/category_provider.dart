import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:spendulum/models/category.dart';
import 'package:spendulum/db/database_helper.dart';
import 'package:spendulum/ui/widgets/logger.dart';
import 'package:spendulum/utils/category_utils.dart';
import 'package:spendulum/db/tables/category_table.dart';

/// A provider class that manages the state and operations related to
/// categories in the application. It handles loading, adding, updating,
/// and removing categories from the database, as well as maintaining
/// a local list of categories. This class extends ChangeNotifier to
/// notify listeners of any changes in the category data.
class CategoryProvider with ChangeNotifier {
  List<Category> _categories = [];
  List<Category> get categories => _categories;

  /// Loads categories from the database.
  /// If no categories are found, it creates default categories.
  Future<void> loadCategories() async {
    AppLogger.info('Loading categories from the database');
    try {
      // First, load existing categories from database
      _categories = await _loadCategoriesFromDatabase();

      // Only create default categories if none exist
      if (_categories.isEmpty) {
        AppLogger.info('No categories found, creating default categories');
        await _createDefaultCategories();
      } else {
        AppLogger.info('Loaded ${_categories.length} existing categories');
      }

      notifyListeners();
    } catch (e) {
      AppLogger.error('Error loading categories from the database', error: e);
    }
  }

  /// Creates default categories if none exist.
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
    AppLogger.info('Default categories created successfully');
  }

  /// Adds a category to the database.
  Future<void> _addCategoryToDatabase(Category category) async {
    AppLogger.info('Adding category to the database: ${category.name}');
    await DatabaseHelper.instance.insert(CategoriesTable.tableName, {
      CategoriesTable.columnId: category.id,
      CategoriesTable.columnName: category.name,
      CategoriesTable.columnColor: category.color,
      CategoriesTable.columnIcon: category.icon,
    });
    AppLogger.info('Category added to the database: ${category.id}');
  }

  /// Adds a new custom category.
  Future<void> addCategory(String name, String color, String icon) async {
    AppLogger.info('Adding new custom category: $name');
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
      AppLogger.info('Custom category added successfully: ${newCategory.id}');
    } catch (e) {
      AppLogger.error('Error adding custom category', error: e);
    }
  }

  /// Removes a category by its ID.
  Future<void> removeCategory(String id) async {
    AppLogger.info('Removing category with ID: $id');
    try {
      await DatabaseHelper.instance.delete(
        CategoriesTable.tableName,
        CategoriesTable.columnId,
        id,
      );

      _categories.removeWhere((category) => category.id == id);
      notifyListeners();
      AppLogger.info('Category removed successfully: $id');
    } catch (e) {
      AppLogger.error('Error removing category with ID: $id', error: e);
    }
  }

  /// Updates a category's details.
  Future<void> updateCategory(
      String id, String name, String color, String icon) async {
    AppLogger.info('Updating category with ID: $id');
    try {
      final updatedCategory = Category(
        id: id,
        name: name,
        color: color,
        icon: icon,
      );

      await DatabaseHelper.instance.update(
        CategoriesTable.tableName,
        {
          CategoriesTable.columnName: updatedCategory.name,
          CategoriesTable.columnColor: updatedCategory.color,
          CategoriesTable.columnIcon: updatedCategory.icon,
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
      AppLogger.error('Error updating category with ID: $id', error: e);
    }
  }

  /// Retrieves a category by its ID.
  Category? getCategoryById(String id) {
    AppLogger.info('Retrieving category with ID: $id');
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      AppLogger.warn('Category not found with ID: $id');
      return null;
    }
  }

  Future<List<Category>> _loadCategoriesFromDatabase() async {
    final categoryMaps =
        await DatabaseHelper.instance.queryAllRows(CategoriesTable.tableName);
    return categoryMaps
        .map((map) => Category(
              id: map[CategoriesTable.columnId] as String,
              name: map[CategoriesTable.columnName] as String,
              color: map[CategoriesTable.columnColor] as String,
              icon: map[CategoriesTable.columnIcon] as String,
            ))
        .toList();
  }
}
