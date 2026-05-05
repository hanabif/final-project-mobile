import 'package:complaint_resolution_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:complaint_resolution_app/features/auth/data/models/auth_response_model.dart';
import 'package:complaint_resolution_app/features/auth/data/models/user_model.dart';
import 'package:complaint_resolution_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:complaint_resolution_app/features/auth/domain/repositories/session_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeRemote extends AuthRemoteDataSource {
  @override
  Future<AuthResponseModel> login(String email, String password) async {
    if (email == 'bad@creds' || password == 'bad') {
      throw Exception('invalid credentials');
    }
    // return a dummy user and token
    return AuthResponseModel(
      user: const UserModel(id: '42', name: 'Alice', email: 'alice@mail.com', role: 'Citizen'),
      token: 'sometoken',
    );
  }

  @override
  Future<AuthResponseModel> register(
    String name,
    String email,
    String password,
    String role,
  ) async {
    return AuthResponseModel(
      user: const UserModel(id: '555', name: 'Bob', email: 'bob@mail.com', role: 'Citizen'),
      token: 'newtoken',
    );
  }

  @override
  Future<void> forgotPassword(String email) async {}

  @override
  Future<void> verifyCode(String email, String code) async {}

  @override
  Future<void> resetPassword(String email, String newPassword) async {}
}

class FakeSession implements SessionRepository {
  String? stored;
  @override
  Future<void> clearSession() async {
    stored = null;
  }

  @override
  Future<String?> getToken() async => stored;

  @override
  Future<bool> hasValidSession() async => stored != null;

  @override
  Future<void> saveToken(String token) async {
    stored = token;
  }
}

void main() {
  late FakeRemote remote;
  late FakeSession session;
  late AuthRepositoryImpl repo;

  setUp(() {
    remote = FakeRemote();
    session = FakeSession();
    repo = AuthRepositoryImpl(remote, session);
  });

  test('login success stores token and returns user', () async {
    final user = await repo.login('a@b.com', 'pw');
    expect(user.email, 'alice@mail.com');
    expect(session.stored, 'sometoken');
  });

  test('login failure propagates exception and does not store', () async {
    expect(() => repo.login('bad@creds', 'pw'), throwsA(isA<Exception>()));
    expect(session.stored, isNull);
  });

  test('register success stores token and returns user', () async {
    final user = await repo.register('name', 'e@mail.com', 'pw', 'Citizen');
    expect(user.id, '555');
    expect(session.stored, 'newtoken');
  });
}
