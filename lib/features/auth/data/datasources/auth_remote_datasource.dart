import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String name, String email, String password);
  Future<void> forgotPassword(String email);
  Future<void> verifyCode(String email, String code);
  Future<void> resetPassword(String email, String newPassword);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl(this.apiClient);

  @override
  Future<UserModel> login(String email, String password) async {
    final response = await apiClient.dio.post(
      '/login',
      data: {
        "email": email,
        "password": password,
      },
    );

    return UserModel.fromJson(response.data['user']);
  }

  @override
  Future<UserModel> register(String name, String email, String password) async {
    final response = await apiClient.dio.post(
      '/register',
      data: {
        "name": name,
        "email": email,
        "password": password,
      },
    );

    return UserModel.fromJson(response.data['user']);
  }

  @override
  Future<void> forgotPassword(String email) async {
    await apiClient.dio.post(
      '/forgot-password',
      data: {
        "email": email,
      },
    );
  }

  @override
  Future<void> verifyCode(String email, String code) async {
    await apiClient.dio.post(
      '/verify-code',
      data: {
        "email": email,
        "code": code,
      },
    );
  }

  @override
  Future<void> resetPassword(String email, String newPassword) async {
    await apiClient.dio.post(
      '/reset-password',
      data: {
        "email": email,
        "password": newPassword,
      },
    );
  }

}
