import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../../domain/repositories/session_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SessionRepository sessionRepository;

  AuthRepositoryImpl(this.remoteDataSource, this.sessionRepository);

  @override
  Future<User> login(String email, String password) async {
    final authResponse = await remoteDataSource.login(email, password);
    
    // Validate user role - only Citizens are allowed to login
    if (authResponse.user.role.toLowerCase() != 'citizen') {
      throw Exception(
        'Unauthorized: Only citizens are authorized to access this application. '
        'Your role is ${authResponse.user.role}.',
      );
    }
    
    // Store tokens immediately after successful login
    await sessionRepository.saveToken(authResponse.accessToken);
    await sessionRepository.saveRefreshToken(authResponse.refreshToken);
    return authResponse.user;
  }

  @override
  Future<User> register(
    String name,
    String email,
    String password,
    String role,
  ) async {
    final authResponse = await remoteDataSource.register(
      name,
      email,
      password,
      role,
    );
    
    // Validate user role - only Citizens are allowed to register and use the app
    if (authResponse.user.role.toLowerCase() != 'citizen') {
      throw Exception(
        'Registration failed: Only citizens can register for this application.',
      );
    }
    
    // Store tokens immediately after successful registration
    await sessionRepository.saveToken(authResponse.accessToken);
    await sessionRepository.saveRefreshToken(authResponse.refreshToken);
    return authResponse.user;
  }

  @override
  Future<void> forgotPassword(String email) async {
    // The remote API only exposes OTP-based forgot-password. Delegate
    // to the OTP endpoint to send a code to the user's email.
    return await remoteDataSource.forgotPasswordOtp(email);
  }

  @override
  Future<void> forgotPasswordOtp(String email) async {
    return await remoteDataSource.forgotPasswordOtp(email);
  }

  @override
  Future<void> verifyCode(String email, String code) async {
    // The remote API does not provide a verify-code endpoint. Perform a
    // lightweight local verification step (mock) so the presentation
    // layer can continue to use the same flow.
    await Future.delayed(const Duration(milliseconds: 500));
    return;
  }

  @override
  Future<void> resetPassword(
    String email,
    String token,
    String newPassword,
  ) async {
    return await remoteDataSource.resetPassword(email, token, newPassword);
  }

  @override
  Future<void> resetPasswordOtp(
    String email,
    String code,
    String newPassword,
  ) async {
    return await remoteDataSource.resetPasswordOtp(email, code, newPassword);
  }

  @override
  Future<User> getProfile() async {
    return await remoteDataSource.getProfile();
  }

  @override
  Future<User> updateProfile(String fullName) async {
    return await remoteDataSource.updateProfile(fullName);
  }

  @override
  Future<void> changePassword(String oldPassword, String newPassword) async {
    return await remoteDataSource.changePassword(oldPassword, newPassword);
  }

  @override
  Future<void> logout() async {
    await remoteDataSource.logout();
    await sessionRepository.clearSession();
  }
}
