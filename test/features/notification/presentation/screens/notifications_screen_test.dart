import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:complaint_resolution_app/features/notification/presentation/screens/notifications_screen.dart';
import 'package:complaint_resolution_app/features/notification/presentation/cubit/notification_cubit.dart';
import 'package:complaint_resolution_app/features/notification/domain/entities/notification_item.dart';
import 'package:complaint_resolution_app/features/settings/presentation/cubits/settings_cubit.dart';
import 'package:complaint_resolution_app/features/settings/presentation/cubits/settings_state.dart';
import 'package:complaint_resolution_app/features/settings/domain/entities/user_settings.dart';
import 'package:complaint_resolution_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MockNotificationCubit extends Mock implements NotificationCubit {}

class MockSettingsCubit extends Mock implements SettingsCubit {}

void main() {
  late MockNotificationCubit mockNotificationCubit;
  late MockSettingsCubit mockSettingsCubit;

  setUp(() {
    mockNotificationCubit = MockNotificationCubit();
    mockSettingsCubit = MockSettingsCubit();

    // Stub close to avoid errors
    when(() => mockNotificationCubit.close()).thenAnswer((_) async {});
    when(() => mockSettingsCubit.close()).thenAnswer((_) async {});

    // Stub stream to avoid Null subtype errors
    when(
      () => mockNotificationCubit.stream,
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => mockSettingsCubit.stream,
    ).thenAnswer((_) => const Stream.empty());

    // Stub default settings state
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
      supportedLocales: const [Locale('en', '')],
      home: MultiBlocProvider(
        providers: [
          BlocProvider<NotificationCubit>.value(value: mockNotificationCubit),
          BlocProvider<SettingsCubit>.value(value: mockSettingsCubit),
        ],
        child: child,
      ),
    );
  }

  testWidgets('renders loading state', (tester) async {
    when(() => mockNotificationCubit.state).thenReturn(NotificationLoading());

    await tester.pumpWidget(createTestableWidget(const NotificationsScreen()));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders empty state when no notifications', (tester) async {
    when(
      () => mockNotificationCubit.state,
    ).thenReturn(NotificationLoaded(const []));

    await tester.pumpWidget(createTestableWidget(const NotificationsScreen()));
    await tester.pumpAndSettle();

    expect(find.textContaining('No notifications'), findsOneWidget);
  });

  testWidgets('renders list of notifications when loaded', (tester) async {
    final notifications = [
      NotificationItem(
        id: '1',
        title: 'Title 1',
        body: 'Body 1',
        date: DateTime.now(),
        isRead: false,
      ),
      NotificationItem(
        id: '2',
        title: 'Title 2',
        body: 'Body 2',
        date: DateTime.now().subtract(const Duration(hours: 1)),
        isRead: true,
      ),
    ];

    when(
      () => mockNotificationCubit.state,
    ).thenReturn(NotificationLoaded(notifications));

    await tester.pumpWidget(createTestableWidget(const NotificationsScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Title 1'), findsOneWidget);
    expect(find.text('Title 2'), findsOneWidget);
    expect(find.text('Body 1'), findsOneWidget);
    expect(find.text('Body 2'), findsOneWidget);
  });

  testWidgets('calls markAllAsRead when "Mark all as read" is pressed', (
    tester,
  ) async {
    final notifications = [
      NotificationItem(
        id: '1',
        title: 'Title 1',
        body: 'Body 1',
        date: DateTime.now(),
        isRead: false,
      ),
    ];

    when(
      () => mockNotificationCubit.state,
    ).thenReturn(NotificationLoaded(notifications));
    when(() => mockNotificationCubit.markAllAsRead()).thenAnswer((_) async {});

    await tester.pumpWidget(createTestableWidget(const NotificationsScreen()));
    await tester.pumpAndSettle();

    final markAllButton = find.byIcon(Icons.done_all_rounded);
    await tester.tap(markAllButton);
    await tester.pump();

    verify(() => mockNotificationCubit.markAllAsRead()).called(1);
  });

  testWidgets('shows connection lost view when state is NotificationError', (
    tester,
  ) async {
    // We need to emit the error state via a stream if the listener is to pick it up properly,
    // but BlocProvider.value and state stubbing works too if we pump correctly.
    whenListen(
      mockNotificationCubit,
      Stream.fromIterable([NotificationError('Error loading')]),
      initialState: NotificationInitial(),
    );

    await tester.pumpWidget(createTestableWidget(const NotificationsScreen()));
    await tester.pump(); // Start the listener

    expect(find.text('Connection Lost!'), findsOneWidget);
  });
}

// Helper for mocktail when using cubits and streams
void whenListen(
  MockNotificationCubit mock,
  Stream<NotificationState> stream, {
  required NotificationState initialState,
}) {
  when(() => mock.state).thenReturn(initialState);
  when(() => mock.stream).thenAnswer((_) => stream);
}
