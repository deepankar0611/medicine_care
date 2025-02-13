// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'dart:math';
//
// class NotificationService {
//   static final FlutterLocalNotificationsPlugin _notificationsPlugin =
//   FlutterLocalNotificationsPlugin();
//
//   static Future<void> init() async {
//     const AndroidInitializationSettings androidSettings =
//     AndroidInitializationSettings('@mipmap/ic_launcher');
//
//     const InitializationSettings settings =
//     InitializationSettings(android: androidSettings);
//
//     await _notificationsPlugin.initialize(settings);
//   }
//
//   static Future<void> scheduleNotification(
//       int id, String title, String body, tz.TZDateTime scheduledTime) async {
//     await _notificationsPlugin.zonedSchedule(
//       id,
//       title,
//       body,
//       scheduledTime,
//       const NotificationDetails(
//         android: AndroidNotificationDetails(
//           'medicine_channel',
//           'Medicine Reminders',
//           importance: Importance.high,
//           priority: Priority.high,
//         ),
//       ),
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // ✅ Updated for latest API
//       uiLocalNotificationDateInterpretation:
//       UILocalNotificationDateInterpretation.absoluteTime,
//     );
//   }
//
//   static tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
//     final now = tz.TZDateTime.now(tz.local);
//     tz.TZDateTime scheduledDate = tz.TZDateTime(
//         tz.local, now.year, now.month, now.day, time.hour, time.minute);
//
//     return scheduledDate.isBefore(now)
//         ? scheduledDate.add(const Duration(days: 1))
//         : scheduledDate;
//   }
//
//   static void scheduleMedicineReminders(
//       List<TimeOfDay> times, String medicineName) {
//     for (var time in times) {
//       final id = Random().nextInt(100000);
//       scheduleNotification(id, "Medicine Reminder",
//           "Time to take $medicineName", _nextInstanceOfTime(time));
//     }
//   }
// }


