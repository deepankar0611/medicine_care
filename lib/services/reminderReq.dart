import 'package:permission_handler/permission_handler.dart';

Future<void> reminderPermission() async {
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
  if (await Permission.scheduleExactAlarm.isDenied) {
    await Permission.scheduleExactAlarm.request();
  }
}