import 'package:flutter/material.dart';
import 'package:spendulum/services/reminder_service.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:spendulum/models/reminder.dart';

class ReminderProvider extends ChangeNotifier {
  final ReminderService _reminderService = ReminderService();
  final String _storageKey = 'reminders';
  List<ReminderModel> _reminders = [];
  bool _isInitialized = false;

  List<ReminderModel> get reminders => List.unmodifiable(_reminders);

  Future<void> initialize() async {
    if (!_isInitialized) {
      await _reminderService.initialize();
      await loadReminders();
      _isInitialized = true;
    }
  }

  Future<void> loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final remindersJson = prefs.getStringList(_storageKey) ?? [];
    _reminders = remindersJson
        .map((json) => ReminderModel.fromJson(jsonDecode(json)))
        .toList();
    notifyListeners();
  }

  Future<void> saveReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final remindersJson =
        _reminders.map((reminder) => jsonEncode(reminder.toJson())).toList();
    await prefs.setStringList(_storageKey, remindersJson);
  }

  Future<void> addReminder(ReminderModel reminder) async {
    _reminders.add(reminder);
    await _reminderService.scheduleReminder(
      id: reminder.id,
      time: reminder.time,
      selectedDays: reminder.selectedDays,
    );
    await saveReminders();
    notifyListeners();
  }

  Future<void> removeReminder(int id) async {
    _reminders.removeWhere((reminder) => reminder.id == id);
    await _reminderService.cancelReminder(id);
    await saveReminders();
    notifyListeners();
  }

  Future<void> toggleReminder(int id) async {
    final index = _reminders.indexWhere((reminder) => reminder.id == id);
    if (index != -1) {
      final reminder = _reminders[index];
      final updatedReminder = ReminderModel(
        id: reminder.id,
        time: reminder.time,
        selectedDays: reminder.selectedDays,
        isActive: !reminder.isActive,
      );

      _reminders[index] = updatedReminder;

      if (updatedReminder.isActive) {
        await _reminderService.scheduleReminder(
          id: updatedReminder.id,
          time: updatedReminder.time,
          selectedDays: updatedReminder.selectedDays,
        );
      } else {
        await _reminderService.cancelReminder(updatedReminder.id);
      }

      await saveReminders();
      notifyListeners();
    }
  }

  ReminderService get reminderService => _reminderService;
}
