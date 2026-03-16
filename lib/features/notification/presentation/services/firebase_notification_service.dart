import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../../../core/utils/scaffold_messenger_key.dart';

class FirebaseNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final NotificationRepository _repository;

  FirebaseNotificationService(this._repository);

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
        
        _showNotificationSnackbar(
          message.notification?.title ?? "New Notification",
          message.notification?.body ?? "",
        );
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
      
      if (token != null) {
        await _repository.registerDeviceToken(token);
        debugPrint("FCM Token registered with backend successfully");
      }
      
      return token;
    } catch (e) {
      debugPrint("Error getting or registering FCM token: $e");
      return null;
    }
  }

  void _handleMessage(RemoteMessage message) {
    debugPrint("Handling notification message: ${message.messageId}");
    // Add navigation or specific logic here
  }

  void _showNotificationSnackbar(String title, String body) {
    if (scaffoldMessengerKey.currentState == null) return;

    scaffoldMessengerKey.currentState!.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        backgroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
        content: Row(
          children: [
            const Icon(Icons.notifications_active, color: Color(0xFF6C63FF)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    body,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'View',
          textColor: const Color(0xFF6C63FF),
          onPressed: () {
            // Add navigation logic if needed
          },
        ),
      ),
    );
  }
}

// Top-level function for background message handling
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling a background message: ${message.messageId}");
}
