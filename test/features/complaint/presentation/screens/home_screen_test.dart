import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:complaint_resolution_app/features/complaint/presentation/screens/home_screen.dart';
import 'package:complaint_resolution_app/features/complaint/presentation/cubits/home/home_cubit.dart';
import 'package:complaint_resolution_app/features/complaint/presentation/cubits/home/home_state.dart';
import 'package:complaint_resolution_app/features/notification/presentation/cubit/notification_cubit.dart';
import 'package:complaint_resolution_app/features/settings/presentation/cubits/settings_cubit.dart';
import 'package:complaint_resolution_app/features/settings/presentation/cubits/settings_state.dart';
import 'package:complaint_resolution_app/features/settings/domain/entities/user_settings.dart';
import 'package:complaint_resolution_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MockHomeCubit extends Mock implements HomeCubit {}
class MockNotificationCubit extends Mock implements NotificationCubit {}
class MockSettingsCubit extends Mock implements SettingsCubit {}

void main() {
  late MockHomeCubit mockHomeCubit;
  late MockNotificationCubit mockNotificationCubit;
  late MockSettingsCubit mockSettingsCubit;

  setUp(() {
    mockHomeCubit = MockHomeCubit();
    mockNotificationCubit = MockNotificationCubit();
    mockSettingsCubit = MockSettingsCubit();

    when(() => mockHomeCubit.close()).thenAnswer((_) async {});
    when(() => mockNotificationCubit.close()).thenAnswer((_) async {});
    when(() => mockSettingsCubit.close()).thenAnswer((_) async {});

    when(() => mockHomeCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockNotificationCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockSettingsCubit.stream).thenAnswer((_) => const Stream.empty());

    when(() => mockHomeCubit.loadHomeData(forceRefresh: any(named: 'forceRefresh'))).thenAnswer((_) async {});
    when(() => mockNotificationCubit.fetchNotifications()).thenAnswer((_) async {});

    when(() => mockSettingsCubit.state).thenReturn(
      const SettingsLoaded(
        settings: UserSettings(
          isAnonymousMode: false,
          isNotificationsEnabled: true,
          themeMode: 'Light',
          language: 'en',
        ),
      ),
    );
  });

  Widget createTestableWidget(Widget child) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
      ],
      home: MultiBlocProvider(
        providers: [
          BlocProvider<HomeCubit>.value(value: mockHomeCubit),
          BlocProvider<NotificationCubit>.value(value: mockNotificationCubit),
          BlocProvider<SettingsCubit>.value(value: mockSettingsCubit),
        ],
        child: child,
      ),
    );
  }

  testWidgets('renders Home Screen correctly with loaded data', (tester) async {
    when(() => mockHomeCubit.state).thenReturn(const HomeLoaded(
      totalComplaints: 10,
      resolvedComplaints: 7,
      pendingComplaints: 3,
      organizations: [],
    ));
    when(() => mockNotificationCubit.state).thenReturn(NotificationInitial());

    await tester.pumpWidget(createTestableWidget(const HomeScreen()));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('10'), findsOneWidget); // Total complaints
    expect(find.text('7'), findsOneWidget);  // Resolved
    expect(find.text('3'), findsOneWidget);  // Pending
  });

  testWidgets('shows loading indicator when HomeLoading', (tester) async {
    when(() => mockHomeCubit.state).thenReturn(HomeLoading());
    when(() => mockNotificationCubit.state).thenReturn(NotificationInitial());

    await tester.pumpWidget(createTestableWidget(const HomeScreen()));
    
    // We expect a CircularProgressIndicator somewhere in the body
    expect(find.byType(CircularProgressIndicator), findsWidgets);
  });

  testWidgets('shows error message when HomeError', (tester) async {
    when(() => mockHomeCubit.state).thenReturn(const HomeError(message: 'Failed to load'));
    when(() => mockNotificationCubit.state).thenReturn(NotificationInitial());

    await tester.pumpWidget(createTestableWidget(const HomeScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Failed to load'), findsOneWidget);
  });
}
