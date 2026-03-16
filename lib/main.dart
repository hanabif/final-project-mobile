import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'core/di/injection_container.dart' as di;
import 'core/di/injection_container.dart';
import 'features/notification/presentation/services/firebase_notification_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('--- APP STARTING ---');
  try {
    debugPrint('Initializing Dependency Injection...');
    await di.init();
    debugPrint('Dependency Injection Initialized Successfully.');

    debugPrint('Initializing Firebase...');
    await Firebase.initializeApp();
    
    debugPrint('Initializing Notifications...');
    await sl<FirebaseNotificationService>().initialize();
    await sl<FirebaseNotificationService>().getDeviceToken();

    runApp(const ComplaintResolutionApp());
    debugPrint('runApp executed.');
  } catch (e, stack) {
    debugPrint('CRITICAL ERROR DURING INITIALIZATION: $e');
    debugPrint('STACK TRACE: $stack');
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Initialization Error: $e'),
        ),
      ),
    ));
  }
}
