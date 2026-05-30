import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:complaint_resolution_app/features/auth/presentation/pages/register_page.dart';
import 'package:complaint_resolution_app/features/auth/presentation/cubit/auth/auth_cubit.dart';
import 'package:complaint_resolution_app/features/auth/presentation/cubit/auth/auth_state.dart';
import 'package:complaint_resolution_app/core/di/injection_container.dart'
    as di;
import 'package:complaint_resolution_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';

class MockAuthCubit extends Mock implements AuthCubit {}

void main() {
  late MockAuthCubit mockAuthCubit;

  setUpAll(() async {
    final sl = GetIt.instance;
    await sl.reset();
    mockAuthCubit = MockAuthCubit();
    sl.registerFactory<AuthCubit>(() => mockAuthCubit);
  });

  setUp(() {
    reset(mockAuthCubit);
    when(() => mockAuthCubit.close()).thenAnswer((_) async {});
    when(() => mockAuthCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget createTestableWidget() {
    return const MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale('en', '')],
      home: RegisterPage(),
    );
  }

  testWidgets('renders RegisterPage correctly', (tester) async {
    when(() => mockAuthCubit.state).thenReturn(AuthInitial());

    await tester.pumpWidget(createTestableWidget());

    expect(find.text('Register'), findsNWidgets(2)); // Title and Button
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Your Password'), findsOneWidget);
    expect(find.text('Your Name'), findsOneWidget);
  });

  testWidgets('shows validation errors when fields are empty', (tester) async {
    when(() => mockAuthCubit.state).thenReturn(AuthInitial());

    await tester.pumpWidget(createTestableWidget());

    await tester.tap(find.text('Register').last);
    await tester.pump();

    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Name is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets('calls register on AuthCubit when form is valid', (tester) async {
    when(() => mockAuthCubit.state).thenReturn(AuthInitial());
    when(
      () => mockAuthCubit.register(any(), any(), any()),
    ).thenAnswer((_) async {});

    await tester.pumpWidget(createTestableWidget());

    // Enter text in TextForms
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'test@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'John Doe');
    await tester.enterText(find.byType(TextFormField).at(2), 'Password123!');

    await tester.pump(); // Allow state to update (e.g. for Strength indicator)

    await tester.tap(find.text('Register').last);
    await tester.pumpAndSettle();

    verify(
      () => mockAuthCubit.register(
        'John Doe',
        'test@example.com',
        'Password123!',
      ),
    ).called(1);
  });

  testWidgets('shows loading state when AuthLoading', (tester) async {
    when(() => mockAuthCubit.state).thenReturn(AuthLoading());

    await tester.pumpWidget(createTestableWidget());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
