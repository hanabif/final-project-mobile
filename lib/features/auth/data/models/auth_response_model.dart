import 'user_model.dart';
import '../../domain/entities/user.dart';

/// Represents the authentication response from both login and register endpoints.
/// Both endpoints return tokens and user data at the root level of the JSON response.
class AuthResponseModel {
  final User user;
  final String accessToken;
  final String refreshToken;
  final int expiresIn; // Token expiration time in seconds

  AuthResponseModel({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    this.expiresIn = 900, // Default to 15 minutes if not provided
  });

  /// Legacy property for backward compatibility with existing code.
  String get token => accessToken;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    try {
      // Parse user data from response (handles both register and login formats)
      final user = UserModel.fromJson(json);

      // Extract tokens—both endpoints return accessToken and refreshToken at root level
      final accessToken = json['accessToken']?.toString().trim() ?? '';
      final refreshToken = json['refreshToken']?.toString().trim() ?? '';
      final expiresIn = json['expiresIn'] is int ? json['expiresIn'] as int : 900;

      if (accessToken.isEmpty || refreshToken.isEmpty) {
        throw Exception(
          'Missing required tokens in response: '
          'accessToken=${accessToken.isEmpty ? "missing" : "present"}, '
          'refreshToken=${refreshToken.isEmpty ? "missing" : "present"}',
        );
      }

      return AuthResponseModel(
        user: user,
        accessToken: accessToken,
        refreshToken: refreshToken,
        expiresIn: expiresIn,
      );
    } catch (e) {
      print('Error parsing AuthResponseModel: $e, json: $json');
      rethrow;
    }
  }
}
