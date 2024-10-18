import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final Function(String?) onSaved;
  final String? initialValue;
  final TextInputType? keyboardType;
  final VoidCallback? onTap; // Add optional onTap callback
  final Color? textColor; // Add textColor parameter

  const CustomTextField({
    Key? key,
    required this.label,
    required this.onSaved,
    this.initialValue,
    this.keyboardType,
    this.onTap, // Include onTap in the constructor
    this.textColor, // Include textColor in the constructor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Wrap in GestureDetector to handle onTap
      onTap: onTap,
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: textColor), // Apply textColor here
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        initialValue: initialValue,
        keyboardType: keyboardType,
        validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
        onSaved: onSaved,
      ),
    );
  }
}
