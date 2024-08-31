import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart'; // Add this package to handle opening settings

class MyNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Get device token
  Future<String?> getDeviceToken() async {
    String? token = await _firebaseMessaging.getToken();
    return token;
  }

  void isTokenRefreshed() async {
    _firebaseMessaging.onTokenRefresh.listen((token) {
      print('Refreshed Token: $token');
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
}
