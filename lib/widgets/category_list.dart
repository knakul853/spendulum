import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budget_buddy/providers/category_provider.dart';

class CategoryList extends StatelessWidget {
  const CategoryList({super.key});

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return ListView.builder(
      itemCount: categoryProvider.categories.length,
      itemBuilder: (ctx, index) {
        final category = categoryProvider.categories[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor:
                Color(int.parse('0xff${category.color.substring(1)}')),
            radius: 20,
          ),
          title: Text(category.name),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              categoryProvider.removeCategory(category.id);
              debugPrint('Category deleted: ${category.id}');
            },
          ),
        );
      },
    );
  }
}
