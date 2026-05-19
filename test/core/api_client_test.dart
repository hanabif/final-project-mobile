import 'dart:convert';

import 'package:complaint_resolution_app/core/network/api_client.dart';
import 'package:complaint_resolution_app/features/auth/domain/repositories/session_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSessionRepository extends Mock implements SessionRepository {}

class RecordingAdapter implements HttpClientAdapter {
  late RequestOptions recorded;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future? cancelFuture,
  ) async {
    recorded = options;
    // return dummy 200 response body
    return ResponseBody.fromString('ok', 200);
  }
}

void main() {
  late MockSessionRepository mockSession;

  setUp(() {
    mockSession = MockSessionRepository();
    // Default behaviors to avoid Null Pointer exception on un-stubbed methods
    when(() => mockSession.getRefreshToken()).thenAnswer((_) async => null);
    when(() => mockSession.clearSession()).thenAnswer((_) async => {});
  });

  test('ApiClient attaches token if present and not expired', () async {
    final adapter = RecordingAdapter();
    final validJwt = makeJwt(secondsFromNow: 3600);
    when(() => mockSession.getToken()).thenAnswer((_) async => validJwt);

    final client = ApiClient(mockSession);
    client.dio.httpClientAdapter = adapter;

    await client.dio.get('/foo', options: Options(extra: {'no-auth': false}));

    expect(adapter.recorded.headers['Authorization'], 'Bearer $validJwt');
  });

  test('ApiClient does not attach header if token null', () async {
    final adapter = RecordingAdapter();
    when(() => mockSession.getToken()).thenAnswer((_) async => null);

    final client = ApiClient(mockSession);
    client.dio.httpClientAdapter = adapter;

    await client.dio.get('/foo', options: Options(extra: {'no-auth': false}));

    expect(adapter.recorded.headers['Authorization'], isNull);
  });
}

// Helper to generate a dummy JWT for token expiration checks
String makeJwt({required int secondsFromNow}) {
  final header = base64Url
      .encode(utf8.encode('{"alg":"HS256","typ":"JWT"}'))
      .replaceAll('=', '');
  final expiry =
      (DateTime.now().millisecondsSinceEpoch ~/ 1000) + secondsFromNow;
  final payload = base64Url
      .encode(utf8.encode('{"exp": $expiry}'))
      .replaceAll('=', '');
  return '$header.$payload.signature';
}
