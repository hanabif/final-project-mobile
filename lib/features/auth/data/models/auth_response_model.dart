import 'user_model.dart';

class AuthResponseModel {
  final UserModel user;
  final String token;

  AuthResponseModel({required this.user, required this.token});

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    try {
      return AuthResponseModel(
        user: UserModel.fromJson((json['user'] as Map<String, dynamic>?) ?? {}),
        token: json['token']?.toString() ?? '',
      );
    } catch (e) {
      print('Error parsing AuthResponseModel: $e, json: $json');
      rethrow;
    }
  }
}
