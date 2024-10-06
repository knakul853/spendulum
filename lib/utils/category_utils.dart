import 'package:spendulum/models/category.dart';
import 'package:spendulum/constants/app_constants.dart';
import 'package:uuid/uuid.dart';

class CategoryUtils {
  static Category createCategory(String name) {
    final lowercaseName = name.toLowerCase();
    return Category(
        id: const Uuid().v4(),
        name: name,
        color: AppConstants.categoryColors[lowercaseName] ?? 'CCCCCC',
        icon: lowercaseName);
  }
}
