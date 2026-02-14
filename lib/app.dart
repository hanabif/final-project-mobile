import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';

class ComplaintResolutionApp extends StatelessWidget {
  const ComplaintResolutionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Complaint Resolution App',
      theme: AppTheme.lightTheme,
      home: const Scaffold(
        body: Center(
          child: Text('App Initialized'),
        ),
      ),
    );
  }
}
