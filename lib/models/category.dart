import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final String color;
  final IconData icon; // New icon field

  Category({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
  });
}
