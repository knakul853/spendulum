import 'package:flutter/material.dart';

class ReminderModel {
  final int id;
  final TimeOfDay time;
  final List<int> selectedDays;
  final bool isActive;

  ReminderModel({
    required this.id,
    required this.time,
    required this.selectedDays,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'time': '${time.hour}:${time.minute}',
      'selectedDays': selectedDays,
      'isActive': isActive,
    };
  }

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    final timeParts = json['time'].split(':');
    return ReminderModel(
      id: json['id'],
      time: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
      selectedDays: List<int>.from(json['selectedDays']),
      isActive: json['isActive'],
    );
  }

  String get formattedDays {
    const dayNames = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return selectedDays.map((day) => dayNames[day]).join(', ');
  }
}
