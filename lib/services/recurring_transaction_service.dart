import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:spendulum/ui/widgets/logger.dart';
import 'package:spendulum/services/service_locator.dart';
import 'package:spendulum/providers/recurring_transaction_provider.dart';

class RecurringTransactionService {
  static const String notificationChannelId = 'recurring_transactions';
  static const String notificationChannelName = 'Recurring Transactions';
  static const String notificationChannelDescription =
      'Notifications for recurring transactions';

  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    // Configure notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      notificationChannelId,
      notificationChannelName,
      description: notificationChannelDescription,
      importance: Importance.low,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: notificationChannelId,
        initialNotificationTitle: 'Recurring Transactions Service',
        initialNotificationContent: 'Running in background',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );

    // Initialize service locator before starting the service
    setupServiceLocator();
    await service.startService();
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    return true;
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();

    if (service is AndroidServiceInstance) {
      service.setAsForegroundService();
    }

    // Initialize service locator in the background isolate
    setupServiceLocator();

    service.on('stopService').listen((event) {
      service.stopSelf();
    });

    // Run the recurring transaction check every hour
    Timer.periodic(
      const Duration(hours: 1),
      (timer) async {
        AppLogger.info('Background service: Processing recurring transactions');

        try {
          final provider = getIt<RecurringTransactionProvider>();
          await provider.processRecurringTransactions();

          if (service is AndroidServiceInstance) {
            service.setForegroundNotificationInfo(
              title: 'Recurring Transactions',
              content: 'Last checked: ${DateTime.now().toString()}',
            );
          }

          AppLogger.info(
              'Background service: Successfully processed transactions');
        } catch (e) {
          AppLogger.error('Background service error', error: e);
        }
      },
    );
  }
}
