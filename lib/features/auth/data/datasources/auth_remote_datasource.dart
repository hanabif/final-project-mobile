import '../../../../core/network/api_client.dart';
import '../models/auth_response_model.dart';

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
        "fullname": name,
        "email": email,
        "password": password,
        "role": role,
      },
    );

    return AuthResponseModel.fromJson(response.data);
  }

  @override
  Future<void> forgotPassword(String email) async {
    await apiClient.dio.post('/forgot-password', data: {"email": email});
  }

  @override
  Future<void> verifyCode(String email, String code) async {
    await apiClient.dio.post(
      '/verify-code',
      data: {"email": email, "code": code},
    );
  }

  @override
  Future<void> resetPassword(String email, String newPassword) async {
    await apiClient.dio.post(
      '/reset-password',
      data: {"email": email, "password": newPassword},
    );
  }
}
