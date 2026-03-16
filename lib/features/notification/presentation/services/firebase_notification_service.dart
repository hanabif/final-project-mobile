import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FirebaseNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Request permission
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      debugPrint('User granted provisional permission');
    } else {
      debugPrint('User declined or has not accepted permission');
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint('Message also contained a notification: ${message.notification}');
      }
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // Get initial message if app was opened from a terminated state
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Handle when app is in background but opened via notification
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  Future<String?> getDeviceToken() async {
    try {
      String? token = await _fcm.getToken();
      debugPrint("FCM Token: $token");
      return token;
    } catch (e) {
      debugPrint("Error getting FCM token: $e");
      return null;
    }
  }

  void _handleMessage(RemoteMessage message) {
    debugPrint("Handling notification message: ${message.messageId}");
    // Add navigation or specific logic here
  }
}

// Top-level function for background message handling
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `Firebase.initializeApp()` before using other Firebase services.
  debugPrint("Handling a background message: ${message.messageId}");
}
