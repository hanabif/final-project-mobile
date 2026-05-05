import 'package:complaint_resolution_app/core/network/api_client.dart';
import 'package:complaint_resolution_app/features/auth/domain/repositories/session_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class DummySession implements SessionRepository {
  final String? token;
  DummySession(this.token);

  @override
  Future<void> clearSession() async {}

  @override
  Future<String?> getToken() async => token;

  @override
  Future<bool> hasValidSession() async => token != null;

  @override
  Future<void> saveToken(String token) async {}
}

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
  test('ApiClient attaches token if present', () async {
    final adapter = RecordingAdapter();
    final client = ApiClient(DummySession('mytoken'));
    client.dio.httpClientAdapter = adapter;

    await client.dio.get('/foo');

    expect(adapter.recorded.headers['Authorization'], 'Bearer mytoken');
  });

  test('ApiClient does not attach header if token null', () async {
    final adapter = RecordingAdapter();
    final client = ApiClient(DummySession(null));
    client.dio.httpClientAdapter = adapter;

    await client.dio.get('/foo');

    expect(adapter.recorded.headers['Authorization'], isNull);
  });
}
