import 'dart:convert';

import 'package:complaint_resolution_app/core/utils/secure_storage.dart';
import 'package:complaint_resolution_app/features/auth/data/repositories/session_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSecureStorageService extends Mock implements SecureStorageService {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

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
  late MockSecureStorageService mockSecureStorage;
  late MockSharedPreferences mockSharedPreferences;
  late SessionRepositoryImpl repo;

  setUp(() {
    mockSecureStorage = MockSecureStorageService();
    mockSharedPreferences = MockSharedPreferences();
    repo = SessionRepositoryImpl(mockSecureStorage, mockSharedPreferences);
  });

  test('saveToken and getToken return correct value', () async {
    when(() => mockSecureStorage.saveToken(any())).thenAnswer((_) async => {});
    when(() => mockSecureStorage.getToken()).thenAnswer((_) async => 'abc123');

    await repo.saveToken('abc123');
    expect(await repo.getToken(), 'abc123');
  });

  test('clearSession removes stored token and clears prefs', () async {
    when(() => mockSecureStorage.clearToken()).thenAnswer((_) async => {});
    when(
      () => mockSharedPreferences.remove(any()),
    ).thenAnswer((_) async => true);

    await repo.clearSession();

    verify(() => mockSecureStorage.clearToken()).called(1);
    verify(() => mockSharedPreferences.remove(any())).called(3);
  });

  test('hasValidSession returns false when no token', () async {
    when(() => mockSecureStorage.getToken()).thenAnswer((_) async => null);
    expect(await repo.hasValidSession(), isFalse);
  });

  test('hasValidSession returns true when token exists', () async {
    when(
      () => mockSecureStorage.getToken(),
    ).thenAnswer((_) async => 'valid-token');
    expect(await repo.hasValidSession(), isTrue);
  });
}
