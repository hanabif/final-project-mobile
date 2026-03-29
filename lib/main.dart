import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'core/di/injection_container.dart';
import 'features/notification/presentation/services/firebase_notification_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  debugPrint('--- APP STARTING ---');
  
  // 1. Initialize Dependency Injection first
  try {
    debugPrint('Initializing Dependency Injection...');
    await init();
    debugPrint('Dependency Injection Initialized Successfully.');
  } catch (e) {
    debugPrint('DI Initialization Error: $e');
  }

  // 2. Start UI immediately (Crucial for avoiding blank screen)
  runApp(const ComplaintResolutionApp());
  debugPrint('runApp executed.');

  // 3. Initialize Firebase & Notifications in the background gracefully
  _initializeFirebaseAndNotifications();
}

Future<void> _initializeFirebaseAndNotifications() async {
  try {
    debugPrint('Initializing Firebase (Background)...');
    await Firebase.initializeApp().timeout(const Duration(seconds: 3));
    
    if (Firebase.apps.isNotEmpty) {
      debugPrint('Firebase Initialized. Setting up notifications...');
      final notificationService = sl<FirebaseNotificationService>();
      await notificationService.initialize();
      await notificationService.getDeviceToken();
    }
  } catch (e) {
    debugPrint('Firebase/Notification Init skipped or failed: $e');
    // We do not call runApp here to avoid replacing the working app with an error screen
  }
}
