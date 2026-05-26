import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'app.dart';
import 'core/di/injection_container.dart';
import 'core/network/deep_link_service.dart';
import 'features/notification/presentation/services/firebase_notification_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  
  // 1. Initialize Dependency Injection first
  try {
    await init();
  } catch (e) {
    debugPrint('DI Initialization Error: $e');
  }

  // 2. Initialize DeepLinkService
  sl<DeepLinkService>().initialize();

  // 3. Start UI immediately (Crucial for avoiding blank screen)
  // Register background message handler before runApp so background isolates are set up
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(const ComplaintResolutionApp());

  // 4. Initialize Firebase & Notifications in the background gracefully
  _initializeFirebaseAndNotifications();
}

Future<void> _initializeFirebaseAndNotifications() async {
  try {
    await Firebase.initializeApp().timeout(const Duration(seconds: 10));
    
    if (Firebase.apps.isNotEmpty) {
      final notificationService = sl<FirebaseNotificationService>();
      await notificationService.initialize();
      await notificationService.getDeviceToken();
    }
  } catch (e) {
    debugPrint('Firebase/Notification Init skipped or failed: $e');
    // We do not call runApp here to avoid replacing the working app with an error screen
  }
}
