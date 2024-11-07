import 'package:flutter/material.dart';
import 'package:spendulum/services/reminder_service.dart';

class ReminderProvider extends ChangeNotifier {
  final ReminderService _reminderService = ReminderService();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (!_isInitialized) {
      await _reminderService.initialize();
      _isInitialized = true;
    }
  }

  ReminderService get reminderService => _reminderService;
}
