import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medicine_care/home_page.dart';
import 'package:medicine_care/login_screen.dart';
import 'package:workmanager/workmanager.dart';
import 'firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  await supabase.Supabase.initialize(
    url: 'https://xzoyevujxvqaumrdskhd.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh6b3lldnVqeHZxYXVtcmRza2hkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzkyMTE1MjMsImV4cCI6MjA1NDc4NzUyM30.mbV_Scy2fXbMalxVRGHNKOxYx0o6t-nUPmDLlH5Mr_U',
  );

  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  await AndroidAlarmManager.initialize();
  
  runApp(const MyApp());
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.subscribeToTopic("med_reminders");
    return Future.value(true);
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _setupFirebaseMessaging();
  }

  void _setupFirebaseMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permission for notifications
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint("User granted permission for notifications.");
    } else {
      debugPrint("User denied notification permissions.");
    }

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("FCM Foreground Message: ${message.notification?.title}");
    });

    // Subscribe to topic for reminders
    await messaging.subscribeToTopic("med_reminders");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            return const HomePage(); // User is logged in
          } else {
            return const LoginScreen(); // User is not logged in
          }
        },
      ),
    );
  }
}
