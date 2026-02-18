import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String name, String email, String password);
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
}
