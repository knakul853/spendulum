import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:spendulum/ui/widgets/logger.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

class ReminderService {
  static final ReminderService _instance = ReminderService._internal();
  factory ReminderService() => _instance;
  ReminderService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    print('Initializing ReminderService...');

    // Initialize timezone
    try {
      tz.initializeTimeZones();
      final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
      AppLogger.info('Current Timezone: $currentTimeZone');
      tz.setLocalLocation(tz.getLocation(currentTimeZone));
      print('Timezone initialized successfully');
    } catch (e) {
      print('Error initializing timezone: $e');
      rethrow;
    }
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
      onDidReceiveNotificationResponse:
          (NotificationResponse response) async {},
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    AppLogger.info('ReminderService initialized successfully');

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
      print('Adjusting scheduled date to $scheduledDate');
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
        AppLogger.info(
            'Scheduling reminder for day: ${tz.TZDateTime.now(tz.local)}');
        final scheduledDate = _nextInstanceOfTime(time, day);
        print('Scheduling reminder with ID $id on $scheduledDate');

        await flutterLocalNotificationsPlugin
            .zonedSchedule(
          androidScheduleMode: AndroidScheduleMode.exact,
          id + day,
          'Expense Reminder',
          'Don\'t forget to add your expenses for today!',
          tz.TZDateTime.now(tz.local),
          NotificationDetails(
            android: AndroidNotificationDetails(
              'expense_reminders_$id',
              'Expense Reminders',
              channelDescription: 'Reminders for adding expenses',
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
        )
            .then((_) {
          print('Reminder with ID $id scheduled successfully');
        }).catchError((error) {
          print('Error scheduling reminder with ID $id: $error');
        });
      }

      print('Scheduled reminders for days: $selectedDays');
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

  // Test method to schedule an immediate notification
  Future<void> scheduleTestNotification() async {
    print('Scheduling test notification...');

    try {
      await flutterLocalNotificationsPlugin.show(
        0,
        'Test Notification',
        'This is a test notification',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'expense_reminders',
            'Expense Reminders',
            channelDescription: 'Notifications for expense reminders',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
      print('Test notification scheduled successfully');
    } catch (e) {
      print('Error scheduling test notification: $e');
      rethrow;
    }
  }
}
