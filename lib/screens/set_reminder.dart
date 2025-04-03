import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  runApp(const WaterReminderApp());
}

class WaterReminderApp extends StatelessWidget {
  const WaterReminderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WaterReminderScreen(),
    );
  }
}

class WaterReminderScreen extends StatefulWidget {
  const WaterReminderScreen({super.key});

  @override
  _WaterReminderScreenState createState() => _WaterReminderScreenState();
}

class _WaterReminderScreenState extends State<WaterReminderScreen> {
  int _interval = 1; // Default: 1 hour
  String _lastReminder = "No reminders set yet";

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _interval = prefs.getInt('reminder_interval') ?? 1;
      _lastReminder = prefs.getString('lastReminder') ?? "No reminders set yet";
    });
  }

  void _setReminderInterval() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('reminder_interval', _interval);

    setState(() {
      _lastReminder = "Reminder set for every $_interval hour(s)";
    });

    NotificationService().scheduleNotification(_interval);

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Reminder set for every $_interval hour(s)!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Water Reminder 💧")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Set Water Reminder Interval", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            DropdownButton<int>(
              value: _interval,
              items: [1, 2, 3, 4, 5, 6].map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text("$value hour(s)"),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() => _interval = newValue);
                }
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _setReminderInterval,
              child: const Text("Set Reminder"),
            ),
            const SizedBox(height: 20),
            Text(_lastReminder,
                style: const TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings =
        InitializationSettings(android: androidInit);
    await _notifications.initialize(settings);
  }

  Future<void> showNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'water_reminder_channel',
      'Water Reminder',
      channelDescription: 'Reminds you to drink water',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await _notifications.show(
        0, "Time to Drink Water! 💧", "Stay hydrated!", details);
  }

  Future<void> scheduleNotification(int hours) async {
    await _notifications.cancelAll();

    tz.TZDateTime scheduledTime =
        tz.TZDateTime.now(tz.local).add(Duration(hours: hours));

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'water_reminder_channel',
      'Water Reminder',
      channelDescription: 'Scheduled water drinking reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await _notifications.zonedSchedule(
      0,
      "Time to Drink Water! 💧",
      "Stay hydrated!",
      scheduledTime,
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}
