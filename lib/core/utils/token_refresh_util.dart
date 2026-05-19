import 'package:jwt_decoder/jwt_decoder.dart';

/// Utility class for JWT token operations and validation.
class TokenRefreshUtil {
  /// Check if a JWT token is expired.
  /// Returns true if the token is expired or malformed.
  static bool isTokenExpired(String? token) {
    if (token == null || token.isEmpty) return true;

    try {
      return JwtDecoder.isExpired(token);
    } catch (e) {
      // Malformed tokens are treated as expired to trigger re-authentication
      print('Token validation error: $e');
      return true;
    }
  }

  /// Extract the expiration datetime from a JWT token.
  /// Returns null if the token is invalid.
  static DateTime? getTokenExpirationDate(String? token) {
    if (token == null || token.isEmpty) return null;

    try {
      return JwtDecoder.getExpirationDate(token);
    } catch (e) {
      print('Failed to extract expiration date: $e');
      return null;
    }
  }

  /// Get the remaining time until token expiration in seconds.
  /// Returns -1 if the token is already expired.
  static int getRemainingSeconds(String? token) {
    if (token == null || token.isEmpty) return -1;

    try {
      final expirationDate = JwtDecoder.getExpirationDate(token);
      final now = DateTime.now();
      if (expirationDate.isBefore(now)) return -1;
      return expirationDate.difference(now).inSeconds;
    } catch (e) {
      print('Failed to get remaining time: $e');
      return -1;
    }
  }

  /// Decode JWT token and extract payload as a map.
  /// Returns empty map if decoding fails.
  static Map<String, dynamic> decodeToken(String? token) {
    if (token == null || token.isEmpty) return {};

    try {
      return JwtDecoder.decode(token);
    } catch (e) {
      print('Failed to decode token: $e');
      return {};
    }
  }
}
