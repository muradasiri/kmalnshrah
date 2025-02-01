import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: DarwinInitializationSettings(),
    );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Request notification permissions for iOS
    FirebaseMessaging.instance.requestPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        showNotification(
          message.notification?.title ?? 'No Title',
          message.notification?.body ?? 'No Body',
        );
      }
    });
  }

  static Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'your_channel_id', // Use your channel id here
      'your_channel_name', // Use your channel name here
      channelDescription: 'your_channel_description', // Use your channel description here
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
        0, title, body, platformChannelSpecifics, payload: 'item x');
  }

  static Future<void> sendNotification(String memberId, String title, String message) async {
    // Your logic to send notification to a specific user
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'your_channel_id', // Use your channel id here
      'your_channel_name', // Use your channel name here
      channelDescription: 'your_channel_description', // Use your channel description here
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
        0, title, message, platformChannelSpecifics, payload: 'item x');
  }

  // Function to send FCM notification
  static Future<void> sendFCMNotification(String fcmToken, String title, String body) async {
    final String serverKey = 'AIzaSyCNUB0-pR7XD-2K4cjnmRxd2dwKYFI7fGw'; // استبدلها بمفتاح الخادم الخاص بك من FCM

    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
        body: jsonEncode(<String, dynamic>{
          'to': fcmToken,
          'notification': <String, dynamic>{
            'title': title,
            'body': body,
          },
        }),
      );
    } catch (e) {
      print('Error sending FCM notification: $e');
    }
  }
}
