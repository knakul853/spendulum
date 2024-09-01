import 'package:flutter/material.dart';

class Account {
  final String id;
  final String name;
  final String accountNumber;
  final String accountType;
  double balance;
  final Color color;
  final String currency;
  final DateTime createdAt;
  DateTime updatedAt; // New field

  Account({
    required this.id,
    required this.name,
    required this.accountNumber,
    required this.accountType,
    required this.balance,
    required this.color,
    required this.currency,
    required this.createdAt,
    required this.updatedAt, // New parameter
  });
}
