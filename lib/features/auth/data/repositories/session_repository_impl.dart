import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/utils/secure_storage.dart';
import '../../domain/repositories/session_repository.dart';
import '../../../complaint/data/datasources/complaint_local_data_source.dart';

class SessionRepositoryImpl implements SessionRepository {
  final SecureStorageService _secureStorage;
  final SharedPreferences _sharedPreferences;

  SessionRepositoryImpl(this._secureStorage, this._sharedPreferences);

  @override
  Future<void> saveToken(String token) {
    return _secureStorage.saveToken(token);
  }

  @override
  Future<String?> getToken() {
    return _secureStorage.getToken();
  }

  @override
  Future<void> clearSession() async {
    await _secureStorage.clearToken();
    try {
      await _sharedPreferences.remove(CACHED_ORGANIZATIONS);
      await _sharedPreferences.remove(CACHED_COMPLAINTS);
      await _sharedPreferences.remove(CACHED_UNSUBMITTED_COMPLAINTS);
    } catch (_) {
      // ignore errors when clearing optional cached keys
    }
  }

  @override
  Future<void> saveRefreshToken(String token) {
    return _secureStorage.saveRefreshToken(token);
  }

  @override
  Future<String?> getRefreshToken() {
    return _secureStorage.getRefreshToken();
  }

  @override
  Future<bool> hasValidSession() async {
    final token = await _secureStorage.getToken();
    return token != null && token.isNotEmpty;
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
