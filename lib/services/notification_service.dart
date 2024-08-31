import 'dart:io';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class MyNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Get device token
  Future<String?> getDeviceToken() async {
    String? token = await _firebaseMessaging.getToken();
    return token;
  }

  void isTokenRefreshed() async {
    _firebaseMessaging.onTokenRefresh.listen((token) {
      debugPrint('Refreshed Token: $token');
    });
  }

  // Request notification permission
  void requestNotificationsPermission(BuildContext context) async {
    print('Checking current permission status...');
    NotificationSettings currentSettings =
        await _firebaseMessaging.getNotificationSettings();

    // Check the current permission status before requesting permission
    if (currentSettings.authorizationStatus == AuthorizationStatus.denied) {
      print('User has denied notifications in settings.');
      // Prompt the user to open app settings
      _showOpenSettingsDialog(context);
      return;
    }

    // Requesting permission
    print('Requesting Permission for Notifications...');
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      sound: true,
      provisional: false, // Ensure full permissions are requested
    );

    // Handle different authorization statuses
    switch (settings.authorizationStatus) {
      // For Android
      case AuthorizationStatus.authorized:
        print('User granted full permission');
        break;
      // For iOS
      case AuthorizationStatus.provisional:
        print(
            'User granted provisional permission; notifications are delivered quietly.');
        break;
      case AuthorizationStatus.denied:
        print('User denied permission');
        // Prompt to open settings if permission is denied
        _showOpenSettingsDialog(context);
        break;
      case AuthorizationStatus.notDetermined:
        print('User has not yet determined permission status.');
        break;
    }
  }

  // Show a dialog to open app settings when permission is denied
  void _showOpenSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Notifications Disabled'),
          content: const Text(
              'Notifications are disabled. To enable them, go to your app settings and allow notifications.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // Open the app's notification settings
                await openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

// Initializes Firebase Messaging to listen for incoming notifications
  void firebaseInit() async {
    // Listens for messages when the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Prints the notification title and body to the console
      debugPrint("NotificationTitle: ${message.notification?.title}");
      debugPrint("NotificationBody: ${message.notification?.body}");

      // Checks if the platform is Android before proceeding
      if (Platform.isAndroid) {
        // Initializes local notifications settings
        initLocalNotifications();
        // Displays the notification locally on the device
        _showNotifications(message);
      }
    });
  }

// Initializes local notifications settings for Android and iOS
  void initLocalNotifications() async {
    // Android-specific initialization settings, using the app launcher icon
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS-specific initialization settings
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    // Combines Android and iOS initialization settings
    var initializationSettings = const InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Initializes the local notifications plugin with the specified settings
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (payload) async {
      // Prints the notification response payload when a notification is tapped
      debugPrint('Notification Response: $payload');
    });
  }

// Displays the notification using the local notifications plugin
  Future<void> _showNotifications(RemoteMessage message) async {
    // Creates a channel for Android notifications with a unique channel ID
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      Random.secure().nextInt(100000).toString(),
      // Generates a random channel ID
      'High Importance Notifications', // Channel name
      // Sets the importance level of the notification channel
      importance: Importance.max,
    );

    // Creates the details for Android notifications, including priority and importance
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      channel.id.toString(),
      channel.name.toString(),
      channelDescription: 'Your Channel Description',
      // Description of the channel
      importance: Importance.high,
      // Ensures the notification is shown immediately
      priority: Priority.high,
      // Sets high priority for the notification
      ticker: 'ticker', // Optional ticker text for older Android versions
    );

    // Creates the details for iOS notifications
    DarwinNotificationDetails darwinNotificationDetails =
        const DarwinNotificationDetails(
            presentAlert: true, // Shows alert on screen
            presentBadge: true, // Shows a badge on the app icon
            presentSound:
                true); // Plays a sound when the notification is received

    // Combines Android and iOS notification details into a unified object
    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    // Displays the notification on the device using the plugin
    Future.delayed(Duration.zero, () async {
      await _flutterLocalNotificationsPlugin.show(
        0, // Notification ID
        message.notification?.title, // Notification title
        message.notification?.body, // Notification body
        notificationDetails, // Notification settings for Android and iOS
      );
    });
  }
}
