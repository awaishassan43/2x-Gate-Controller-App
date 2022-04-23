import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
final FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<String> getFCMToken() async {
  try {
    final String? token = await _firebaseMessaging.getToken();

    if (token == null) {
      throw "Got null from the package";
    }

    return token;
  } on FirebaseException catch (e) {
    debugPrint("Firebase Exception: Failed to get fcm token: ${e.message}");
    throw "Failed to get FCM token: ${e.message}";
  } catch (e) {
    debugPrint("Generic Exception: Failed to get FCM token: $e");
    throw "Something went wrong while trying to setup notifications";
  }
}

Future<void> initializeNotifications() async {
  try {
    /// Setting up high priority channel
    /// assigning it to the local notifications handler
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'alerts',
      "Alerts",
      description: "Incoming alerts for the iot device",
      importance: Importance.max,
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Setting up foreground listener and using local notifications package to show it
    FirebaseMessaging.onMessage.listen((message) => _onForegroundNotification(message, channel));

    /// Background notification handler
    FirebaseMessaging.onBackgroundMessage(_onBackgroundNotification);
  } catch (e) {
    debugPrint("Notification initialization failed: $e");
    throw "Failed to intialize the notifications";
  }
}

Future<void> _onBackgroundNotification(RemoteMessage message) async {
  try {
    debugPrint("Received background notification");
  } catch (e) {
    debugPrint("Failed to handle background notification");
  }
}

Future<void> _onForegroundNotification(RemoteMessage message, AndroidNotificationChannel channel) async {
  try {
    debugPrint("Received a foreground notification");
    final RemoteNotification? notification = message.notification;
    final AndroidNotification? android = message.notification?.android;

    // If `onMessage` is triggered with a notification, construct our own
    // local notification to show to users using the created channel.
    if (notification != null && android != null) {
      await _localNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            // other properties...
            color: Colors.blue,
            playSound: true,
            icon: '@mipmap/launcher_icon',
          ),
        ),
      );
    }
  } catch (e) {
    debugPrint("Failed to load the notification: $e");
  }
}
