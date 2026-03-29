import '../../../../core/network/api_client.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  /// returns both user info and auth token returned by the backend
  Future<AuthResponseModel> login(String email, String password);
  Future<AuthResponseModel> register(
    String name,
    String email,
    String password,
    String role,
  );
  Future<void> forgotPassword(String email);
  Future<void> verifyCode(String email, String code);
  Future<void> resetPassword(String email, String newPassword);
  Future<UserModel> getProfile();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl(this.apiClient);

  @override
  Future<AuthResponseModel> login(String email, String password) async {
    final response = await apiClient.dio.post(
      '/auth/login',
      data: {"email": email, "password": password},
    );

    return AuthResponseModel.fromJson(response.data);
  }

  @override
  Future<AuthResponseModel> register(
    String name,
    String email,
    String password,
    String role,
  ) async {
    final response = await apiClient.dio.post(
      '/auth/register',
      data: {
        "fullName": name,
        "email": email,
        "password": password,
      },
    );

    return AuthResponseModel.fromJson(response.data);
  }

  @override
  Future<void> forgotPassword(String email) async {
    await Future.delayed(const Duration(seconds: 1));
    // Mock success
  }

  @override
  Future<void> verifyCode(String email, String code) async {
    await Future.delayed(const Duration(seconds: 1));
    // Mock success
  }

  @override
  Future<void> resetPassword(String email, String newPassword) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<UserModel> getProfile() async {
    final response = await apiClient.dio.get('/auth/profile');
    if (response.statusCode == 200) {
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw Exception('Failed to fetch profile: ${response.statusCode}');
    }
  }
}
