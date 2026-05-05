import 'dart:convert';

import 'package:complaint_resolution_app/core/utils/secure_storage.dart';
import 'package:complaint_resolution_app/features/auth/data/repositories/session_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

/// A fake storage that keeps values in memory instead of using platform
/// channels. It extends [SecureStorageService] so it can be passed to the
/// repository under test.
class FakeSecureStorageService extends SecureStorageService {
  final Map<String, String> _values = {};

  @override
  Future<void> saveToken(String token) async {
    _values['auth_token'] = token;
  }

  @override
  Future<String?> getToken() async {
    return _values['auth_token'];
  }

  @override
  Future<void> clearToken() async {
    _values.remove('auth_token');
  }
}

/// Generate a minimal JWT with an `exp` claim a given number of seconds from
/// now. We do not care about signature, so the last segment is empty.
String makeJwt({required int secondsFromNow}) {
  final header = base64Url.encode(utf8.encode('{"alg":"none"}'));
  final expiry =
      (DateTime.now().millisecondsSinceEpoch ~/ 1000) + secondsFromNow;
  final payload = base64Url.encode(utf8.encode('{"exp":$expiry}'));
  return '$header.$payload.'; // note trailing dot for the signature piece
}

void main() {
  late FakeSecureStorageService fakeStorage;
  late SessionRepositoryImpl repo;

  setUp(() {
    fakeStorage = FakeSecureStorageService();
    repo = SessionRepositoryImpl(fakeStorage);
  });

  test('saveToken and getToken return correct value', () async {
    await repo.saveToken('abc123');
    expect(await repo.getToken(), 'abc123');
  });

  test('clearSession removes stored token', () async {
    await repo.saveToken('xyz');
    await repo.clearSession();
    expect(await repo.getToken(), isNull);
  });

  test('hasValidSession returns false when no token', () async {
    expect(await repo.hasValidSession(), isFalse);
  });

  test('hasValidSession returns false if token is expired', () async {
    final expired = makeJwt(secondsFromNow: -10);
    await repo.saveToken(expired);
    expect(await repo.hasValidSession(), isFalse);
  });

  test('hasValidSession returns true when token is not expired', () async {
    final good = makeJwt(secondsFromNow: 60);
    await repo.saveToken(good);
    expect(await repo.hasValidSession(), isTrue);
  });
}
