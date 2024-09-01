import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final String label;
  final List<String> items;
  final Function(String?) onChanged;
  final String? initialValue;

  const CustomDropdown({
    Key? key,
    required this.label,
    required this.items,
    required this.onChanged,
    this.initialValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          EdgeInsets.symmetric(vertical: 8.0), // Add margin around the widget
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors
                .white, // Change label color to white for better visibility
            shadows: [
              Shadow(
                blurRadius: 3.0,
                color: Colors.black, // Shadow color for better visibility
                offset: Offset(1.0, 1.0), // Shadow offset
              ),
            ],
          ),
          contentPadding: EdgeInsets.symmetric(
              vertical: 10, horizontal: 12), // Add padding around the label
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white, // Keep background color white
        ),
        value: initialValue ?? items[0],
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: TextStyle(
                  color: Colors.black), // Ensure dropdown items are visible
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
