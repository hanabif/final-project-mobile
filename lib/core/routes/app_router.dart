import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/complaint/domain/entities/complaint.dart';
import '../../features/complaint/presentation/screens/home_screen.dart';
import '../../features/complaint/presentation/screens/complaint_form_screen.dart';
import '../../features/complaint/presentation/screens/complaint_success_screen.dart';
import '../../features/complaint/presentation/screens/complaint_status_screen.dart';
import '../../features/complaint/presentation/screens/complaint_list_screen.dart';
import '../../features/settings/presentation/screens/profile_screen.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/verify_code_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/notification/presentation/screens/notifications_screen.dart';
import 'route_names.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splash:
        return MaterialPageRoute(
          builder: (_) => const SplashPage(),
        );

      case RouteNames.login:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
        );

      case RouteNames.register:
        return MaterialPageRoute(
          builder: (_) => const RegisterPage(),
        );

      case RouteNames.home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );

      case RouteNames.complaintForm:
        final organizationId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => ComplaintFormScreen(organizationId: organizationId),
        );

      case RouteNames.complaintSuccess:
        final complaintId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ComplaintSuccessScreen(complaintId: complaintId),
        );

      case RouteNames.complaintStatus:
        final complaint = settings.arguments as Complaint;
        return MaterialPageRoute(
          builder: (_) => ComplaintStatusScreen(complaint: complaint),
        );

      case RouteNames.complaintList:
        return MaterialPageRoute(
          builder: (_) => const ComplaintListScreen(),
        );

      case RouteNames.profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
        );
      
      case RouteNames.forgotPassword:
        final args = settings.arguments as Map<String, dynamic>?;
        final isChangePassword = args?['isChangePassword'] ?? false;
        return MaterialPageRoute(
          builder: (_) => ForgotPasswordPage(isChangePassword: isChangePassword),
        );

      case RouteNames.verifyCode:
        return MaterialPageRoute(
          builder: (_) => const VerifyCodePage(),
        );

      case RouteNames.resetPassword:
        return MaterialPageRoute(
          builder: (_) => const ResetPasswordPage(),
        );

      case RouteNames.notifications:
        return MaterialPageRoute(
          builder: (_) => const NotificationsScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text("No route defined"),
            ),
          ),
        );
    }
  }
}
