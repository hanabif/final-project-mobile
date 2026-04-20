import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login(String email, String password);
  Future<User> register(String name, String email, String password, String role);
  Future<void> forgotPassword(String email);
  Future<void> forgotPasswordOtp(String email);
  Future<void> verifyCode(String email, String code);
  Future<void> resetPassword(String email, String token, String newPassword);
  Future<User> getProfile();
}
