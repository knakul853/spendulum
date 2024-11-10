import 'package:flutter/material.dart';

enum RecurringFrequency { daily, weekly, monthly, yearly, custom }

class RecurringTransaction {
  final String id;
  final String title;
  final double amount;
  final String accountId;
  final String categoryOrSource;
  final String description;
  final RecurringFrequency frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final TimeOfDay? reminderTime;
  final bool isExpense;
  final int? customDays;
  final bool isActive;

  RecurringTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.accountId,
    required this.categoryOrSource,
    required this.description,
    required this.frequency,
    required this.startDate,
    this.endDate,
    this.reminderTime,
    required this.isExpense,
    this.customDays,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'accountId': accountId,
      'categoryOrSource': categoryOrSource,
      'description': description,
      'frequency': frequency.toString(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'reminderTime': reminderTime?.toString(),
      'isExpense': isExpense,
      'customDays': customDays,
      'isActive': isActive,
    };
  }

  factory RecurringTransaction.fromJson(Map<String, dynamic> json) {
    return RecurringTransaction(
      id: json['id'],
      title: json['title'],
      amount: json['amount'],
      accountId: json['accountId'],
      categoryOrSource: json['categoryOrSource'],
      description: json['description'],
      frequency: RecurringFrequency.values.firstWhere(
        (e) => e.toString() == json['frequency'],
      ),
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      reminderTime: json['reminderTime'] != null
          ? TimeOfDay.fromDateTime(DateTime.parse(json['reminderTime']))
          : null,
      isExpense: json['isExpense'],
      customDays: json['customDays'],
      isActive: json['isActive'] ?? true,
    );
  }
}
