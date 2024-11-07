import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final String label;
  final List<String> items;
  final Function(String?) onChanged;
  final String? initialValue;
  final Color? textColor; // Add textColor parameter

  const CustomDropdown({
    Key? key,
    required this.label,
    required this.items,
    required this.onChanged,
    this.initialValue,
    this.textColor, // Include textColor in the constructor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          EdgeInsets.symmetric(vertical: 8.0), // Add margin around the widget
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              Theme.of(context).textTheme.labelMedium?.copyWith(fontSize: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: Theme.of(context).primaryColor.withOpacity(0.5),
                width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.4),
        ),
        value: initialValue ?? items[0],
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: TextStyle(
                  color: textColor ??
                      Theme.of(context).textTheme.bodySmall?.color),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
