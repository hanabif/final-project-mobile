import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class GetProfileUseCase {
  final AuthRepository repository;

  GetProfileUseCase(this.repository);

  Future<User> call() async {
    return await repository.getProfile();
  }
}
