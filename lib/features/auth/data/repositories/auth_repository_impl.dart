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
    // store token as soon as we get it
    await sessionRepository.saveToken(authResponse.token);
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
    await sessionRepository.saveToken(authResponse.token);
    return authResponse.user;
  }

  @override
  Future<void> forgotPassword(String email) async {
    return await remoteDataSource.forgotPassword(email);
  }

  @override
  Future<void> forgotPasswordOtp(String email) async {
    return await remoteDataSource.forgotPasswordOtp(email);
  }

  @override
  Future<void> verifyCode(String email, String code) async {
    return await remoteDataSource.verifyCode(email, code);
  }

  @override
  Future<void> resetPassword(String email, String token, String newPassword) async {
    return await remoteDataSource.resetPassword(email, token, newPassword);
  }

  @override
  Future<User> getProfile() async {
    return await remoteDataSource.getProfile();
  }
}
