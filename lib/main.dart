import 'package:flutter/material.dart';
import 'app.dart';
import 'core/di/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('--- APP STARTING ---');
  try {
    debugPrint('Initializing Dependency Injection...');
    await di.init();
    debugPrint('Dependency Injection Initialized Successfully.');
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
