import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'dart:developer';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notification = FlutterLocalNotificationsPlugin();

  static void init() {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final IOSInitializationSettings initializationSettingsIOS =
    IOSInitializationSettings(
        onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload) async {});

    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    _notification.initialize(initializationSettings);
    tzdata.initializeTimeZones();
  }

  static Future<void> scheduleNotification(int id, String title, String body, DateTime scheduledTime) async {
    try {
      final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'important_notifications',
        'My Channel',
        'This channel is used for important notifications.',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false,
        // Add the following line to set the flag to immutable
        setAsGroupSummary: true, // This is a workaround, usually you would set the actual flag in the platform code
      );

      final IOSNotificationDetails iOSPlatformChannelSpecifics = IOSNotificationDetails();

      final NotificationDetails platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);

      await _notification.zonedSchedule(
          id,
          title,
          body,
          tz.TZDateTime.from(scheduledTime, tz.local),
          platformChannelSpecifics,
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime);
    } catch (e) {
      log('Error scheduling notification: $e');
    }
  }

  static Future<void> cancelAllNotifications() async {
    await _notification.cancelAll();
  }
}
