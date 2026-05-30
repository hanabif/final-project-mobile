import 'package:complaint_resolution_app/features/complaint/presentation/widgets/qr_scanner_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/complaint/domain/entities/complaint.dart';
import '../../features/complaint/presentation/screens/home_screen.dart';
import '../../features/complaint/presentation/screens/complaint_form_screen.dart';
import '../../features/complaint/presentation/screens/complaint_success_screen.dart';
import '../../features/complaint/presentation/screens/complaint_status_screen.dart';
import '../../features/complaint/presentation/screens/complaint_list_screen.dart';
import '../../features/complaint/presentation/cubits/organizations_cubit.dart';
import '../../features/settings/presentation/screens/profile_screen.dart';
import '../../features/settings/presentation/screens/about_screen.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/verify_code_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/notification/presentation/screens/notifications_screen.dart';
import '../../core/di/injection_container.dart';
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
        String? organizationId;
        String? title;
        String? description;
        double? latitude;
        double? longitude;
        String? locationLabel;

        // Handle both string (organizationId) and map (with QR data) arguments
        if (settings.arguments is String) {
          organizationId = settings.arguments as String;
        } else if (settings.arguments is Map) {
          final args = settings.arguments as Map<String, dynamic>;
          organizationId = args['organizationId'] as String?;
          title = args['title'] as String?;
          description = args['description'] as String?;
          latitude = args['latitude'] as double?;
          longitude = args['longitude'] as double?;
          locationLabel = args['locationLabel'] as String?;
        }

        return MaterialPageRoute(
          builder: (_) => BlocProvider<OrganizationsCubit>.value(
            value: sl<OrganizationsCubit>(),
            child: ComplaintFormScreen(
              organizationId: organizationId,
              title: title,
              description: description,
              latitude: latitude,
              longitude: longitude,
              locationLabel: locationLabel,
            ),
          ),
        );

      case RouteNames.complaintSuccess:
        final args = settings.arguments;
        String? complaintId;
        String? message;
        bool isQueued = false;

        if (args is String) {
          complaintId = args;
        } else if (args is Map<String, dynamic>) {
          complaintId = args['complaintId'] as String?;
          message = args['message'] as String?;
          isQueued = args['isQueued'] == true;
        }

        return MaterialPageRoute(
          builder: (_) => ComplaintSuccessScreen(
            complaintId: complaintId,
            message: message,
            isQueued: isQueued,
          ),
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

      case RouteNames.complaintForm:
  final args = settings.arguments as Map<String, dynamic>?;
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => BlocProvider<OrganizationsCubit>.value(
      value: sl<OrganizationsCubit>(),
      child: ComplaintFormScreen(
        organizationId: args?['organizationId'],
        title: args?['title'],
        description: args?['description'],
        latitude: args?['latitude'],
        longitude: args?['longitude'],
      ),
    ),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
      case RouteNames.profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
        );

      case RouteNames.about:
        return MaterialPageRoute(
          builder: (_) => const AboutScreen(),
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

      case RouteNames.qrScanner:
  return MaterialPageRoute(
    builder: (_) => const QRScannerModal(),
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
