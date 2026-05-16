import 'package:dio/dio.dart';
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
  Future<void> forgotPasswordOtp(String email);
  Future<void> verifyCode(String email, String code);
  Future<void> resetPassword(String email, String token, String newPassword);
  Future<void> resetPasswordOtp(String email, String code, String newPassword);
  Future<UserModel> getProfile();
  Future<UserModel> updateProfile(String fullName);
  Future<void> changePassword(String oldPassword, String newPassword);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl(this.apiClient);

  @override
  Future<AuthResponseModel> login(String email, String password) async {
    try {
      final response = await apiClient.dio.post(
        '/auth/login',
        data: {"email": email, "password": password},
        options: Options(extra: {'no-auth': true}),
      );

      if (response.statusCode == 200) {
        return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? e.response?.data['message'] ?? 'Login failed'
          : e.message ?? 'Login failed';
      throw Exception(message);
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  @override
  Future<AuthResponseModel> register(
    String name,
    String email,
    String password,
    String role,
  ) async {
    try {
      final response = await apiClient.dio.post(
        '/auth/register',
        data: {"fullName": name, "email": email, "password": password},
        options: Options(extra: {'no-auth': true}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Registration failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? e.response?.data['message'] ?? 'Registration failed'
          : e.message ?? 'Registration failed';
      throw Exception(message);
    } catch (e) {
      throw Exception('Registration error: $e');
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await apiClient.dio.post('/auth/forgot-password', data: {"email": email});
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? e.response?.data['message'] ?? 'Failed to send reset email'
          : e.message ?? 'Failed to send reset email';
      throw Exception(message);
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  @override
  Future<void> forgotPasswordOtp(String email) async {
    try {
      await apiClient.dio.post(
        '/auth/forgot-password-otp',
        data: {"email": email},
      );
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? e.response?.data['message'] ?? 'Failed to send OTP'
          : e.message ?? 'Failed to send OTP';
      throw Exception(message);
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  @override
  Future<void> verifyCode(String email, String code) async {
    // There is no verify-code endpoint in the screenshots provided.
    // We will treat this as a mock local step as planned.
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> resetPassword(
    String email,
    String token,
    String newPassword,
  ) async {
    try {
      await apiClient.dio.post(
        '/auth/reset-password',
        data: {"email": email, "token": token, "password": newPassword},
      );
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? e.response?.data['message'] ?? 'Failed to reset password'
          : e.message ?? 'Failed to reset password';
      throw Exception(message);
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  @override
  Future<void> resetPasswordOtp(
    String email,
    String code,
    String newPassword,
  ) async {
    try {
      await apiClient.dio.post(
        '/auth/reset-password-otp',
        data: {"email": email, "otp": code, "password": newPassword},
      );
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? e.response?.data['message'] ?? 'Failed to reset password'
          : e.message ?? 'Failed to reset password';
      throw Exception(message);
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  @override
  Future<UserModel> getProfile() async {
    try {
      final response = await apiClient.dio.get('/auth/profile');
      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to fetch profile: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? e.response?.data['message'] ?? 'Failed to fetch profile'
          : e.message ?? 'Failed to fetch profile';
      throw Exception(message);
    } catch (e) {
      throw Exception('Profile fetch error: $e');
    }
  }

  @override
  Future<UserModel> updateProfile(String fullName) async {
    try {
      final response = await apiClient.dio.put(
        '/auth/profile',
        data: {'fullName': fullName},
      );
      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? e.response?.data['message'] ?? 'Failed to update profile'
          : e.message ?? 'Failed to update profile';
      throw Exception(message);
    } catch (e) {
      throw Exception('Profile update error: $e');
    }
  }

  @override
  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      final response = await apiClient.dio.post(
        '/auth/change-password',
        data: {'oldPassword': oldPassword, 'newPassword': newPassword},
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to change password: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? e.response?.data['message'] ?? 'Failed to change password'
          : e.message ?? 'Failed to change password';
      throw Exception(message);
    } catch (e) {
      throw Exception('Password change error: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await apiClient.dio.post('/auth/logout');
    } catch (e) {
      // Ignore errors during logout on the server side
    }
  }
}
