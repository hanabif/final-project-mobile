import 'user_model.dart';
import '../../domain/entities/user.dart';

class AuthResponseModel {
  final User user;
  final String token;
  final String? refreshToken;

  AuthResponseModel({
    required this.user,
    required this.token,
    this.refreshToken,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    try {
      // The screenshot shows user data like _id and role are at the top level
      // alongside accessToken and refreshToken, not nested in a 'user' object.
      final user = UserModel.fromJson(json);
      
      return AuthResponseModel(
        user: user,
        token: json['accessToken']?.toString() ?? json['token']?.toString() ?? '',
        refreshToken: json['refreshToken']?.toString(),
      );
    } catch (e) {
      print('Error parsing AuthResponseModel: $e, json: $json');
      rethrow;
    }
  }
}
