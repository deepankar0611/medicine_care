import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
class LocalNotification {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('logo');

    final DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings();

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );

    if (defaultTargetPlatform == TargetPlatform.android) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'com.example.spendsync',
        'SpendSync Notifications',
        description: 'Receive timely notifications for your spending habits, budget alerts, and important reminders.',
        sound: RawResourceAndroidNotificationSound('notification'),
        importance: Importance.high,
      );

      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  /// Schedule a notification (single or repeated monthly)
  static Future<void> scheduleNotification({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    bool isRepeated = false,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      'com.example.spendsync',
      'SpendSync Notifications',
      channelDescription: 'Receive timely notifications for your spending habits, budget alerts, and important reminders.',
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound('notification'),
      priority: Priority.high,
    );
    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);
    if (isRepeated) {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id.hashCode,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails,
        payload: id,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation
            .absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
      );
    } else {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id.hashCode,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails,
        payload: id,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation
            .absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }

  static Future<void> cancelNotification(String id) async {
    await _flutterLocalNotificationsPlugin.cancel(id.hashCode);
  }

  static Future<void> showSimpleNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      'com.example.medicine_care',
      'Medicine Reminder Notifications',
      channelDescription: '',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('notification'),
      ticker: 'ticker',
    );

    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);

    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
  static Future<void> scheduleNotificationsFromStringList(List<String> timeStrings) async {
    final now = DateTime.now();
    for (var timeString in timeStrings) {
      // Split the string into hour and minute parts.
      final parts = timeString.split(':');
      if (parts.length != 2) continue; // Make sure the format is correct.

      final int hour = int.parse(parts[0]);
      final int minute = int.parse(parts[1]);

      // Create a DateTime object for today with these values.
      DateTime scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);

      // If the scheduled time has already passed today, schedule it for tomorrow.
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      // Create a unique ID for the notification.
      final id = 'notification_${hour}_${minute}';

      // Schedule the notification.
      LocalNotification.scheduleNotification(
        id: id,
        title: 'Reminder',
        body: 'It\'s time for your reminder!',
        scheduledDate: scheduledDate,
        isRepeated: true, // or false if you don't want it to repeat.
      );
    }
  }

}
