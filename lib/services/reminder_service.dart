import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/material.dart';

class ReminderService {
  static final ReminderService _instance = ReminderService._internal();
  factory ReminderService() => _instance;
  ReminderService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    tz.initializeTimeZones();

    // Initialize timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/New_York'));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOSSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
      },
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    _initialized = true;
  }

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time, int dayOfWeek) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    while (scheduledDate.isBefore(now) || scheduledDate.weekday != dayOfWeek) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  Future<void> scheduleReminder({
    required int id,
    required TimeOfDay time,
    required List<int> selectedDays,
  }) async {
    try {
      // Ensure initialization
      await initialize();

      // Cancel existing reminders with the same ID
      await cancelReminder(id);

      for (final day in selectedDays) {
        final scheduledDate = _nextInstanceOfTime(time, day);

        await flutterLocalNotificationsPlugin.zonedSchedule(
          androidScheduleMode: AndroidScheduleMode.exact,
          id + day,
          'Expense Reminder',
          'Don\'t forget to add your expenses for today!',
          scheduledDate,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'expense_reminders_$id', // channel id
              'Expense Reminders', // channel name
              channelDescription:
                  'Reminders for adding expenses', // channel description
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
    } catch (e) {
      print('Error scheduling reminder: $e');
      throw Exception('Failed to schedule reminder: $e');
    }
  }

  Future<void> cancelReminder(int id) async {
    try {
      // Cancel reminders for all days (id + 1 through id + 7)
      for (int i = 1; i <= 7; i++) {
        await flutterLocalNotificationsPlugin.cancel(id + i);
      }
    } catch (e) {
      print('Error canceling reminder: $e');
      throw Exception('Failed to cancel reminder: $e');
    }
  }

  Future<void> cancelAllReminders() async {
    try {
      await flutterLocalNotificationsPlugin.cancelAll();
    } catch (e) {
      print('Error canceling all reminders: $e');
      throw Exception('Failed to cancel all reminders: $e');
    }
  }
}

// reminder_model.dart
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'time': '${time.hour}:${time.minute}',
      'selectedDays': selectedDays,
      'isActive': isActive,
    };
  }

  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    final timeParts = map['time'].split(':');
    return ReminderModel(
      id: map['id'],
      time: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
      selectedDays: List<int>.from(map['selectedDays']),
      isActive: map['isActive'],
    );
  }
}
