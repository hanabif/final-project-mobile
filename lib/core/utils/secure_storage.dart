import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(key: "auth_token", value: token);
  }

  Future<String?> getToken() async {
    return _storage.read(key: "auth_token");
  }

  Future<void> clearToken() async {
    await _storage.delete(key: "auth_token");
    await _storage.delete(key: "refresh_token");
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: "refresh_token", value: token);
  }

  Future<String?> getRefreshToken() async {
    return _storage.read(key: "refresh_token");
  }
}
