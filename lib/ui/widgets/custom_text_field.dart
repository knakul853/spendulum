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
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.4),
        ),
        initialValue: initialValue,
        keyboardType: keyboardType,
        validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
        onSaved: onSaved,
      ),
    );
  }
}
