import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationServices {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static void initilize() {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings("@mipmap/ic_launcher");

    const DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        print('Notification tapped: ${details.payload}');
      },
    );
  }

  static void showNotifiationForground(RemoteMessage message) {
    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'com.autotelnew.android',
        'Best Car Tracker',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        threadIdentifier: 'autotelnew',
      ),
    );

    _notificationsPlugin.show(
      DateTime.now().microsecond,
      message.notification?.title ?? '',
      message.notification?.body ?? '',
      notificationDetails,
    );
  }

  static void showNotifiationForgroundString(String title, String body) {
    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'com.autotelnew.android',
        'Best Car Tracker',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        threadIdentifier: 'autotelnew',
      ),
    );

    _notificationsPlugin.show(
      DateTime.now().microsecond,
      title,
      body,
      notificationDetails,
    );
  }
}
