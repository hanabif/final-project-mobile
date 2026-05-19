import 'package:complaint_resolution_app/core/routes/route_names.dart';
import 'package:complaint_resolution_app/features/auth/presentation/cubit/auth/auth_cubit.dart';
import 'package:complaint_resolution_app/features/auth/presentation/cubit/auth/auth_state.dart';
import 'package:complaint_resolution_app/features/auth/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:complaint_resolution_app/features/auth/domain/entities/user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

class MockAuthCubit extends Mock implements AuthCubit {}

class FakeAuthState extends Fake implements AuthState {}

void main() {
  late MockAuthCubit cubit;

  setUpAll(() {
    registerFallbackValue(FakeAuthState());
  });

  setUp(() {
    cubit = MockAuthCubit();
    when(() => cubit.state).thenReturn(AuthInitial());
    when(() => cubit.close()).thenAnswer((_) async {});
    sl.registerFactory<AuthCubit>(() => cubit);
  });

  tearDown(() {
    sl.reset();
  });

  Widget makeTestable(Widget child, NavigatorObserver observer) {
    return MaterialApp(
      home: BlocProvider<AuthCubit>.value(value: cubit, child: child),
      navigatorObservers: [observer],
      routes: {RouteNames.home: (_) => const Scaffold(body: Text('HOME'))},
    );
  }

  testWidgets('shows success snackbar and navigates on AuthAuthenticated', (
    tester,
  ) async {
    final observer = MockNavigatorObserver();
    whenListen(
      cubit,
      Stream.fromIterable([
        AuthAuthenticated(
          User(id: '1', name: 'x', email: 'x', role: 'Citizen'),
        ),
      ]),
    );
    when(() => cubit.state).thenReturn(
      AuthAuthenticated(User(id: '1', name: 'x', email: 'x', role: 'Citizen')),
    );

    await tester.pumpWidget(makeTestable(const LoginPage(), observer));
    await tester.pump(); // process listener
    await tester.pump(
      const Duration(seconds: 1),
    ); // wait for animations/snackbars

    expect(find.text('Login successful'), findsOneWidget);
    await tester
        .pumpAndSettle(); // finish all animations including snackbar hide
    verify(
      () => observer.didReplace(
        newRoute: any(named: 'newRoute'),
        oldRoute: any(named: 'oldRoute'),
      ),
    ).called(1);
  });

  testWidgets('shows error snackbar on AuthError', (tester) async {
    final observer = MockNavigatorObserver();
    whenListen(
      cubit,
      Stream.fromIterable([AuthError('bad')]),
      initialState: AuthInitial(),
    );

    await tester.pumpWidget(makeTestable(const LoginPage(), observer));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1)); // wait for snackbar

    expect(find.text('bad'), findsOneWidget);
    await tester.pumpAndSettle(); // finish all animations
    verifyNever(
      () => observer.didReplace(
        newRoute: any(named: 'newRoute'),
        oldRoute: any(named: 'oldRoute'),
      ),
    );
  });
}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}
