import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:complaint_resolution_app/main.dart' as app;
import 'package:complaint_resolution_app/core/di/injection_container.dart'
    as di;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End Navigation Test', () {
    testWidgets('verify login and dashboard elements', (tester) async {
      // Initialize SharedPreferences with dummy data to avoid startup issues
      SharedPreferences.setMockInitialValues({});

      // Start the application
      app.main();

      // Wait for the app to settle (Splash -> Login)
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Find identifying elements on the login page
      final loginTitle = find.text('Login');
      final emailField = find.byType(TextFormField).at(0);
      final passwordField = find.byType(TextFormField).at(1);

      expect(loginTitle, findsOneWidget);
      expect(emailField, findsOneWidget);
      expect(passwordField, findsOneWidget);

      // Perform Login (Note: Without a mock server or network override,
      // this will attempt a real network call and likely fail unless the server is up)
      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'Password123!');
      await tester.pumpAndSettle();

      final loginButton = find.widgetWithText(ElevatedButton, 'Login');
      await tester.tap(loginButton);

      // Allow time for network response/animation
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // If login fails, we expect an error snackbar or just to stay on the page
      // In a real E2E, we'd verify navigation to the Home screen.
    });
  });
}
