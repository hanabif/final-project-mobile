import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<User> login(String email, String password) {
    return remoteDataSource.login(email, password);
  }

  @override
  Future<User> register(String name, String email, String password) {
    return remoteDataSource.register(name, email, password);
  }
}
