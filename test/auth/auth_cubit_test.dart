import 'package:bloc_test/bloc_test.dart';
import 'package:complaint_resolution_app/features/auth/domain/entities/user.dart';
import 'package:complaint_resolution_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:complaint_resolution_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:complaint_resolution_app/features/auth/presentation/cubit/auth/auth_cubit.dart';
import 'package:complaint_resolution_app/features/auth/presentation/cubit/auth/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}
class MockRegisterUseCase extends Mock implements RegisterUseCase {}

void main() {
  late MockLoginUseCase loginUseCase;
  late MockRegisterUseCase registerUseCase;
  late AuthCubit cubit;

  setUp(() {
    loginUseCase = MockLoginUseCase();
    registerUseCase = MockRegisterUseCase();
    cubit = AuthCubit(loginUseCase: loginUseCase, registerUseCase: registerUseCase);
  });

  group('login', () {
    final user = User(id: 1, name: 'Test', email: 't@mail.com');

    blocTest<AuthCubit, AuthState>(
      'emits [loading, authenticated] when login succeeds',
      build: () {
        when(() => loginUseCase(any(), any())).thenAnswer((_) async => user);
        return cubit;
      },
      act: (c) => c.login('a', 'b'),
      expect: () => [AuthLoading(), AuthAuthenticated(user)],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [loading, error] when login fails',
      build: () {
        when(() => loginUseCase(any(), any())).thenThrow(Exception('fail'));
        return cubit;
      },
      act: (c) => c.login('a', 'b'),
      expect: () => [AuthLoading(), isA<AuthError>()],
    );
  });

  group('register', () {
    final user = User(id: 2, name: 'Reg', email: 'r@mail.com');

    blocTest<AuthCubit, AuthState>(
      'emits [loading, authenticated] when register succeeds',
      build: () {
        when(() => registerUseCase(any(), any(), any())).thenAnswer((_) async => user);
        return cubit;
      },
      act: (c) => c.register('n', 'e', 'p'),
      expect: () => [AuthLoading(), AuthAuthenticated(user)],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [loading, error] when register fails',
      build: () {
        when(() => registerUseCase(any(), any(), any())).thenThrow(Exception('oops'));
        return cubit;
      },
      act: (c) => c.register('n', 'e', 'p'),
      expect: () => [AuthLoading(), isA<AuthError>()],
    );
  });
}
