import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budget_buddy/providers/category_provider.dart';
import 'package:budget_buddy/widgets/category_list.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  _CategoryManagementScreenState createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  String _categoryName = '';
  Color _categoryColor = Colors.blue; // Default color

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    Provider.of<CategoryProvider>(context, listen: false).addCategory(
      _categoryName,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Category added successfully!')),
    );

    debugPrint(
        'Form submitted with values: name=$_categoryName, color=${_categoryColor.value.toRadixString(16)}');
    Navigator.of(context).pop();
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _categoryColor,
              onColorChanged: (Color color) {
                setState(() {
                  _categoryColor = color;
                });
              },
              pickerAreaHeightPercent: 0.8,
              paletteType: PaletteType.hsvWithHue,
              labelTypes: const [],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Category Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a category name';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _categoryName = value!;
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text('Category Color:',
                          style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: _showColorPicker,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _categoryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey),
                          ),
                          child:
                              const Icon(Icons.color_lens, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Add Category'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Existing Categories:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Expanded(
              child: CategoryList(),
            ),
          ],
        ),
      ),
    );
  }
}
