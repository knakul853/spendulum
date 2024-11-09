import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:spendulum/ui/widgets/logger.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';

class ReminderService {
  // Singleton setup
  static final ReminderService _instance = ReminderService._internal();
  factory ReminderService() => _instance;
  ReminderService._internal();

  // Constants
  static const String _scheduledChannelId = 'scheduled_notifications';
  static const String _scheduledChannelName = 'Scheduled Notifications';
  static const String _scheduledChannelDesc =
      'Channel for scheduled notifications';

  // Instance variables
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // Notification configurations
  static const _androidNotificationDetails = AndroidNotificationDetails(
    _scheduledChannelId,
    _scheduledChannelName,
    channelDescription: _scheduledChannelDesc,
    importance: Importance.max,
    priority: Priority.max,
    enableLights: true,
    enableVibration: true,
    playSound: true,
    category: AndroidNotificationCategory.alarm,
    fullScreenIntent: true,
    visibility: NotificationVisibility.public,
    ticker: 'Scheduled notification',
    icon: "notification",
    autoCancel: true,
    sound: const RawResourceAndroidNotificationSound(
        'notification'), // Make sure this matches your file name
  );

  static const _iosNotificationDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
    sound: 'default',
    badgeNumber: 1,
    interruptionLevel: InterruptionLevel.timeSensitive,
  );

  static const notificationDetails = NotificationDetails(
    android: _androidNotificationDetails,
    iOS: _iosNotificationDetails,
  );

  // Initialization
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      await _initializeTimeZone();
      await _requestPermissions();
      await _setupNotificationChannel();
      await _initializeNotifications();

      _initialized = true;
      AppLogger.info('ReminderService initialized successfully');
    } catch (e) {
      AppLogger.error('Failed to initialize ReminderService: $e');
      rethrow;
    }
  }

  // Private initialization methods
  Future<void> _initializeTimeZone() async {
    tz.initializeTimeZones();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));
    AppLogger.info('Timezone initialized: $currentTimeZone');
  }

  Future<void> _requestPermissions() async {
    // Android permissions
    if (await Permission.notification.isDenied) {
      final status = await Permission.notification.request();
      if (status.isDenied) {
        throw Exception('Notification permissions are required');
      }
    }

    // iOS permissions
    await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> _setupNotificationChannel() async {
    final AndroidNotificationChannel channel = AndroidNotificationChannel(
      _scheduledChannelId,
      _scheduledChannelName,
      description: _scheduledChannelDesc,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      showBadge: true,
      sound: const RawResourceAndroidNotificationSound(
          'notification'), // Make sure this matches your file name
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _initializeNotifications() async {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _handleNotificationResponse,
    );
  }

  void _handleNotificationResponse(NotificationResponse response) {
    AppLogger.info('Notification clicked: ${response.payload}');
  }

  Future<void> scheduleReminder({
    required int id,
    required TimeOfDay time,
    required List<int> selectedDays,
  }) async {
    try {
      await initialize();
      await cancelReminder(id);

      for (final day in selectedDays) {
        final scheduledDate = _getNextInstanceOfTime(time, day);
        await _scheduleReminderForDate(id + day, scheduledDate);
      }
    } catch (e) {
      AppLogger.error('Failed to schedule reminder: $e');
      rethrow;
    }
  }

  // Helper methods
  tz.TZDateTime _getNextInstanceOfTime(TimeOfDay time, int dayOfWeek) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    while (scheduledDate.weekday != dayOfWeek) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  Future<void> _scheduleReminderForDate(
      int id, tz.TZDateTime scheduledDate) async {
    await _notifications.zonedSchedule(
      id,
      'Expense Reminder',
      'Don\'t forget to add your expenses for today!',
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
    AppLogger.info('Reminder scheduled for: ${scheduledDate.toLocal()}');
  }

  // Utility methods
  Future<void> checkActiveNotifications() async {
    final pendingNotifications =
        await _notifications.pendingNotificationRequests();
    AppLogger.info('Pending notifications: ${pendingNotifications.length}');
    for (var notification in pendingNotifications) {
      AppLogger.info('ID: ${notification.id}, Title: ${notification.title}');
    }
  }

  Future<void> cancelReminder(int id) async {
    try {
      for (int i = 1; i <= 7; i++) {
        await _notifications.cancel(id + i);
      }
    } catch (e) {
      AppLogger.error('Failed to cancel reminder: $e');
      rethrow;
    }
  }

  Future<void> cancelAllReminders() async {
    try {
      await _notifications.cancelAll();
    } catch (e) {
      AppLogger.error('Failed to cancel all reminders: $e');
      rethrow;
    }
  }
}
