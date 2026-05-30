import 'package:complaint_resolution_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:complaint_resolution_app/features/auth/data/models/auth_response_model.dart';
import 'package:complaint_resolution_app/features/auth/data/models/user_model.dart';
import 'package:complaint_resolution_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:complaint_resolution_app/features/auth/domain/repositories/session_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockRemote extends Mock implements AuthRemoteDataSource {}
class MockSession extends Mock implements SessionRepository {}

void main() {
  late MockRemote remote;
  late MockSession session;
  late AuthRepositoryImpl repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    remote = MockRemote();
    session = MockSession();
    final sharedPreferences = await SharedPreferences.getInstance();
    repo = AuthRepositoryImpl(remote, session, sharedPreferences);
  });

  const tUser = UserModel(id: '42', name: 'Alice', email: 'alice@mail.com', role: 'Citizen');
  final tAuthResponse = AuthResponseModel(
    user: tUser,
    accessToken: 'sometoken',
    refreshToken: 'refreshtoken',
  );

  test('login success stores token and returns user', () async {
    when(() => remote.login(any(), any())).thenAnswer((_) async => tAuthResponse);
    when(() => session.saveToken(any())).thenAnswer((_) async => {});
    when(() => session.saveRefreshToken(any())).thenAnswer((_) async => {});

    final user = await repo.login('a@b.com', 'pw');
    
    expect(user.email, 'alice@mail.com');
    verify(() => session.saveToken('sometoken')).called(1);
    verify(() => session.saveRefreshToken('refreshtoken')).called(1);
  });

  test('login failure propagates exception and does not store', () async {
    when(() => remote.login(any(), any())).thenThrow(Exception('invalid credentials'));
    
    expect(() => repo.login('bad@creds', 'pw'), throwsA(isA<Exception>()));
    verifyNever(() => session.saveToken(any()));
  });

  test('register success stores token and returns user', () async {
    final tRegResponse = AuthResponseModel(
      user: const UserModel(id: '555', name: 'Bob', email: 'bob@mail.com', role: 'Citizen'),
      accessToken: 'newtoken',
      refreshToken: 'newrefreshtoken',
    );
    when(() => remote.register(any(), any(), any(), any())).thenAnswer((_) async => tRegResponse);
    when(() => session.saveToken(any())).thenAnswer((_) async => {});
    when(() => session.saveRefreshToken(any())).thenAnswer((_) async => {});

    final user = await repo.register('Bob', 'bob@mail.com', 'pw', 'Citizen');
    
    expect(user.id, '555');
    verify(() => session.saveToken('newtoken')).called(1);
  });
}
