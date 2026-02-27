import 'dart:convert';

import '../../../../core/utils/secure_storage.dart';
import '../../domain/repositories/session_repository.dart';

class SessionRepositoryImpl implements SessionRepository {
  final SecureStorageService _secureStorage;

  SessionRepositoryImpl(this._secureStorage);

  @override
  Future<void> saveToken(String token) {
    return _secureStorage.saveToken(token);
  }

  @override
  Future<String?> getToken() {
    return _secureStorage.getToken();
  }

  @override
  Future<void> clearSession() {
    return _secureStorage.clearToken();
  }

  @override
  Future<bool> hasValidSession() async {
    final token = await _secureStorage.getToken();
    if (token == null) return false;
    return !_isTokenExpired(token);
  }

  bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final Map<String, dynamic> map = json.decode(decoded);
      final exp = map['exp'];
      if (exp is int) {
        final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
        return DateTime.now().isAfter(expiry);
      }
    } catch (_) {
      // if anything goes wrong assume expired so we force login again
    }
    return true;
  }
}
