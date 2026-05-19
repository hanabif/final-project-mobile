import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:complaint_resolution_app/core/widgets/password_strength_indicator.dart';
import 'package:complaint_resolution_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  Widget createTestableWidget(Widget child) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', '')],
      home: Scaffold(body: child),
    );
  }

  group('PasswordStrengthIndicator Widget Tests', () {
    testWidgets('should show nothing when password is empty', (tester) async {
      await tester.pumpWidget(
        createTestableWidget(
          const PasswordStrengthIndicator(password: '', isDark: false),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('should show weak strength for short password', (tester) async {
      await tester.pumpWidget(
        createTestableWidget(
          const PasswordStrengthIndicator(password: '123', isDark: false),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('Weak'), findsOneWidget);

      final indicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(indicator.valueColor is AlwaysStoppedAnimation<Color>, isTrue);
      expect(
        (indicator.valueColor as AlwaysStoppedAnimation<Color>).value,
        Colors.red,
      );
    });

    testWidgets('should show strong strength for strong password', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestableWidget(
          const PasswordStrengthIndicator(
            password: 'Strong123!',
            isDark: false,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('Strong'), findsOneWidget);

      final indicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(
        (indicator.valueColor as AlwaysStoppedAnimation<Color>).value,
        Colors.green,
      );
    });

    testWidgets(
      'should display requirement text in correct color for dark mode',
      (tester) async {
        await tester.pumpWidget(
          createTestableWidget(
            const PasswordStrengthIndicator(password: 'pw', isDark: true),
          ),
        );

        await tester.pumpAndSettle();

        final requirementText = tester.widget<Text>(
          find.textContaining('Required:'),
        );
        expect(requirementText.style?.color, Colors.white38);
      },
    );
  });
}
