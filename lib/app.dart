import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'core/routes/app_router.dart';
import 'core/routes/route_names.dart';

class ComplaintResolutionApp extends StatelessWidget {
  const ComplaintResolutionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Complaint Resolution App',
      theme: AppTheme.lightTheme,
      initialRoute: RouteNames.login,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
